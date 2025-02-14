# app/queries/clinician_search.rb

# 
#   
#   ClinicianSearch encapsulates all of the business logic for
#   providing a collection of clinician info to the front-end
#   based upon the FE's query parameters.
#
#   This is an Example of how this end-point
#   will be called:
#
#     api/v1/clinicians?
#       search[age]=23&
#       search[payment_type]=self_pay&
#       search[type_of_cares]=Adult Therapy&
#       search[zip_codes]=44122&
#       page=1&
#       app_name=obie
#
#   The "search" parameters from the URL will be in
#   the "filter" Hash to the "search" method.  The
#   keys will be symbols.
#
# 
#   NOTE: All of the methods for this object are
#         class methods.
#

class ClinicianSearch
  # NOTE: This is NOT the primry entry point.  See
  #       the clinicians_by_location method.
  #
  def self.search(options = {})
    filters = ClinicianSearchOptions.new(options)

    clinician_records = Clinician.active.online_booking_go_live_date
    clinician_records = clinician_records.languages(filters[:languages]) if filters[:languages].present?
    clinician_records = clinician_records.expertises(filters[:expertises]) if filters[:expertises].present?
    clinician_records = clinician_records.concerns(filters[:concerns]) if filters[:concerns].present?
    clinician_records = clinician_records.interventions(filters[:interventions]) if filters[:interventions].present?
    clinician_records = clinician_records.populations(filters[:populations]) if filters[:populations].present?

    clinician_records = clinician_records.clinician_types(filters[:clinician_types]) if filters[:clinician_types].present?

    if filters[:search_term].present?
      clinician_records = clinician_records.filter_by_full_name(filters[:search_term])
      clinician_records = clinician_records.or(clinician_records.filter_by_last_name(filters[:search_term]))
      clinician_records = clinician_records.or(clinician_records.filter_by_first_name(filters[:search_term]))
    end

    clinician_records = clinician_records.with_pronouns(filters.pronouns) if filters.pronouns?

    clinician_records = clinician_records.with_gender(filters.gender) if filters.gender?

    clinician_records = clinician_records.with_license_types(filters[:credentials]) if filters[:credentials].present?

    clinician_records = clinician_records.with_accepted_ages(filters[:age]) if filters[:age].present?

    clinician_records = clinician_records.with_special_cases(filters[:special_cases]) if filters[:special_cases].present?

    clinician_records
  end

  # Main entry point for searching for clinicians
  #
  # options is a Hash whose valid keys are defined
  #         in the ClinicianSearchOptions class
  #
  # Returns an AREL
  #
  def self.clinicians_by_location(options = {})
      filters = ClinicianSearchOptions.new(options)
      home    = PostalCode.find_by(zip_code: filters.zip_codes&.first)

      clinicians_by_address = if !filters.entire_state && filters.distance?
        ClinicianAddress
          .within_miles_of(
            filters.distance, 
                                  home.latitude, home.longitude
          )
          .within_state(home.state)
    
                              elsif home.present?
        ClinicianAddress.include_distance(
          home.latitude,
                                    home.longitude
        )
                              else
          ClinicianAddress
            .with(
              default_distance:
                ClinicianAddress
                .select("
                                        *, 
                                        (0.0)::numeric AS distance_in_miles
                                      ")
            )
            .from("default_distance as clinician_addresses")
                              end

      clinicians_by_address = clinicians_by_address.where(facility_name: filters[:location_names]) if filters[:location_names].present?

      clinicians_by_address = clinicians_by_address.where(facility_id: filters[:facility_ids]) if filters[:facility_ids].present?

      if insurance_payment?(filters[:payment_type]) && valid_insurance?(filters[:insurances])
        clinicians_by_address = clinicians_by_address.with_insurances(filters[:insurances], filters[:app_name])
      end

      # SMELL:  These default availability scopes add duplicate
      #         clinician_address records without additional columns.
      #         both scopes are left_joins.  I think it needs to be
      #         be something else.  At this point all we want to know
      #         does the clinician_address have any availability yes or no.
      #         If no, then the clinician_address should be dropped 
      #         from the collection.
      #
      clinicians_by_address = clinicians_by_address.with_clinician_availability.with_active_availability
      clinicians_by_address = clinicians_by_address.with_type_of_care_availability(filters[:type_of_cares]) if filters[:type_of_cares].present?

      clinicians_by_address = if filters[:patient_status].present? && filters[:patient_status] == "existing"
        clinicians_by_address.existing_patient_clinician_availabilities
                              else
        clinicians_by_address.new_patient_clinician_availabilities
                              end

      if  filters[:availability_filter].present? && 
          filters[:availability_filter].any? { |s| s.include?("after") || s.include?("before") }
        clinicians_by_address = clinicians_by_address.filter_by_availability_time(filters[:availability_filter], filters[:utc_offset])
      end

      if  filters[:availability_filter].present? && 
          filters[:availability_filter].any? { |s| s.include?("next") }
        filter_date = availability_days_filter(filters[:availability_filter], filters[:utc_offset])
        clinicians_by_address = clinicians_by_address.availability_till_date(filter_date)
      end

      # entire_state must be present and true
      # NOTE: "zip_codes" is one and only zip code
      #
      if  filters.entire_state
        clinicians_by_address = clinicians_by_address.within_state(home.state)
      
      elsif filters.zip_codes? && !filters.distance?
        clinicians_by_address = clinicians_by_address.with_zip_code(filters.zip_codes)
      end

      if  filters.modality?
        if filters.modality.include?("in_office") && filters.modality.include?("video_visit")
          clinicians_by_address = clinicians_by_address.with_modality_availabilities
        
        elsif filters.modality.include?("in_office")
          clinicians_by_address = clinicians_by_address.with_in_office_availabilities
        
        elsif filters.modality.include?("video_visit")
          clinicians_by_address = clinicians_by_address.with_virtual_visit_availabilities
        end
      end

      clinicians = search(filters)

      clinicians_by_address = clinicians_by_address.joins(:clinician).merge(clinicians)

      clinicians_by_address = if filters.license_keys?
        clinicians_by_address.with_office_key(filters.license_keys)
                              else
        clinicians_by_address.with_active_office_keys
                              end

      ca_tbl          =  ClinicianAvailability.table_name
      select_clause   =  []
      select_clause   << "clinician_addresses.*"
      select_clause   << "#{ca_tbl}.facility_id"
      select_clause   << "#{ca_tbl}.provider_id"
      select_clause   << "#{ca_tbl}.license_key"
      select_clause   << "#{ca_tbl}.rank_most_available"
      select_clause   << "#{ca_tbl}.rank_soonest_available"
      select_clause   << "clinicians.license_type"

      groupby_clause  =  []
      groupby_clause  << "clinician_addresses.id"
      groupby_clause  << "clinician_addresses.address_line1"
      groupby_clause  << "clinician_addresses.address_line2"
      groupby_clause  << "clinician_addresses.city"
      groupby_clause  << "clinician_addresses.state"
      groupby_clause  << "clinician_addresses.postal_code"
      groupby_clause  << "clinician_addresses.clinician_id"
      groupby_clause  << "clinician_addresses.created_at"
      groupby_clause  << "clinician_addresses.updated_at"
      groupby_clause  << "clinician_addresses.address_code"
      groupby_clause  << "clinician_addresses.office_key"
      groupby_clause  << "clinician_addresses.facility_id"
      groupby_clause  << "clinician_addresses.primary_location"
      groupby_clause  << "clinician_addresses.facility_name"
      groupby_clause  << "clinician_addresses.apt_suite"
      groupby_clause  << "clinician_addresses.country_code"
      groupby_clause  << "clinician_addresses.area_code"
      groupby_clause  << "clinician_addresses.provider_id"
      groupby_clause  << "clinician_addresses.deleted_at"
      groupby_clause  << "clinician_addresses.cbo"
      groupby_clause  << "clinician_addresses.latitude"
      groupby_clause  << "clinician_addresses.longitude"
      groupby_clause  << "clinician_addresses.distance_in_miles" 
      groupby_clause  << "clinician_availability.facility_id"
      groupby_clause  << "clinician_availability.provider_id"
      groupby_clause  << "clinician_availability.license_key"
      groupby_clause  << "clinician_availability.rank_most_available"
      groupby_clause  << "clinician_availability.rank_soonest_available"
      groupby_clause  << "clinicians.license_type"

      clinicians_by_address = clinicians_by_address
                              .select(select_clause.join(", "))
                              .group(groupby_clause.join(", "))



      # The ORDER BY clause should always be the last SQL clause
      # build the sort sequence (sort_seq)
      sort_seq   = []
      
      # sort_seq  << "clinicians.license_type"  if filters.credentials?

      case filters.sort_order
      when "nearest_location"
        sort_seq << "clinician_addresses.distance_in_miles"

      when "soonest_available"
        sort_seq << "#{ClinicianAvailability.table_name}.rank_soonest_available"
      
      when "most_available"
        sort_seq << "#{ClinicianAvailability.table_name}.rank_most_available"
      end  

      clinicians_by_address.order(sort_seq.join(", "))

    # SMELL:  The availability filtering adds the two rank attributes.  It also
    #         duplicates records.  Need to de-dup them.
    #         This is not the complete AREL because in the serializer class
    #         ClinicianSearchSerializer the associations are included and
    #         sub-hashes added....

    # TODO:   Consider using this AREL as a sub-query with where within
    #         the context of the unique_ident, given the sort order we
    #         limit the query to 1.  Don't know how to do that.  If
    #         it is possible it might remove the duplicate problem.
  
  rescue BadParameterError => e
    ErrorLogger.report(e)
    Rails.logger.error e.message
    raise
  end

  def self.get_client_start_end_time(offset)
    end_time = DateTime.now.utc.end_of_day + offset.to_i.minutes
    start_time = DateTime.now.utc.beginning_of_day + offset.to_i.minutes
    [start_time, end_time]
  end

  def self.availability_time_filters(filters, utc_offset)
    filters = filters.select { |s| s.include?("before") || s.include?("after") }
    filters = filters.map(&:downcase)
    before_time = after_time = nil
    filters.each do |filter|
      next unless filter.include?("before") || filter.include?("after")

      filter_time = get_client_equivalent_time(filter, utc_offset)
      before_time = filter_time if filter.include?("before") && (before_time.nil? || filter_time > before_time)
      after_time = filter_time if filter.include?("after") && (after_time.nil? || filter_time < after_time)
    end
    [before_time, after_time]
  end

  def self.get_client_equivalent_time(filter, offset)
    request_time = filter.downcase.split("_")
    hour = request_time[1].to_i
    hour += 12 if request_time[2] == "pm" && hour < 12
    DateTime.now.utc.change({ hour: hour, min: 0, sec: 0 }) + offset.to_i.minutes
  end

  def self.availability_days_filter(filters, utc_offset)
    date_filters = filters.select { |filter| filter.include?("next") }
    selected_date = nil
    time = DateTime.now.utc + utc_offset.to_i.minutes
    next_three_days_buffer = { 0 => 3.days, 1 => 3.days, 2 => 3.days, 3 => 5.days, 4 => 5.days, 5 => 5.days, 6 => 4.days }
    add_time = {
      "next_three_days" => time + next_three_days_buffer[time.wday],
      "next_week" => time + 7.days,
      "next_two_weeks" => time + 14.days,
      "next_month" => time + 1.month
    }
    date_filters.each do |filter|
      filter_date = add_time[filter.downcase.to_s]
      selected_date = filter_date if selected_date.nil? || (filter_date > selected_date)
    end
    selected_date
  end

  def self.insurance_payment?(payment_type)
    payment_type.present? && payment_type == "insurance"
  end

  def self.valid_insurance?(insurance)
    insurance.present? && insurance != "I don’t see my insurance"
  end

  def self.get_available_time(availability_filter, time = Time.now.utc, after_flag = false)
    if after_flag
      time = Time.parse(("12:00 Pm" || time.presence).to_s).utc if availability_filter.include?("after_12_PM")
      time = Time.parse(("3:00 Pm" || time.presence).to_s).utc if availability_filter.include?("after_3_PM")
    elsif availability_filter.any? { |s| s.include?("before") }
      time = Time.parse(("10:00 Am" || time.presence).to_s).utc if availability_filter.include?("before_10_AM")
      time = Time.parse(("12:00 Pm" || time.presence).to_s).utc if availability_filter.include?("before_12_PM")
    end
    time = time.presence || Time.now.utc.change(hour: 23, min: 59, sec: 59)
    add_time = {
      "next_three_Days" => time + 3.days,
      "next_week" => time + 7.days,
      "next_two_Weeks" => time + 14.days,
      "next_month" => time + 1.month
    }
    if availability_filter.any? { |filter| filter.include?("next") }
      filter_index = availability_filter.index { |filter| filter.include?("next") }
      time = add_time[availability_filter[filter_index]]
    else
      time += 90.days
    end
    time
  end
end
