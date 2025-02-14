class ClinicianAvailability < ApplicationRecord
  self.table_name = "clinician_availability"

  self.primary_keys = :provider_id, :license_key, :facility_id

  # If the record exist in ClinicianAvailabilityStatus that means it is already scheduled
  default_scope { where.not(clinician_availability_key: ClinicianAvailabilityStatus.select(:clinician_availability_key)) }

  scope :before_time_appointment_availability, lambda { |time|
                                                 where("#{table_name}.appointment_start_time BETWEEN ?::date AND ?::date AND (extract('hour' from #{table_name}.appointment_start_time) < ?)",
                                                 (
                                                  Time.now.utc + BUSINESS_DAYS[Time.now.utc.strftime("%a")].days).strftime("%Y-%m-%d"),
                                                  time.strftime("%Y-%m-%d"),
                                                  time.hour)
                                               }

  scope :after_time_appointment_availability, lambda { |time|
                                                where("#{table_name}.appointment_start_time BETWEEN ?::date AND ?::date AND (extract('hour' from #{table_name}.appointment_start_time) >= ?)", (Time.now.utc + BUSINESS_DAYS[Time.now.utc.strftime("%a")].to_i.days).strftime("%Y-%m-%d"), time.strftime("%Y-%m-%d"), time.hour)
                                              }

  has_many :clinician_addresses, foreign_key: %i[provider_id office_key facility_id],
                                 primary_key: %i[provider_id license_key facility_id], class_name: "ClinicianAddress"

  scope :with_facility_id, ->(facility_id) { where(facility_id: facility_id) }

  scope :with_facility_ids, ->(facility_ids) { where(facility_id: facility_ids) }


  scope :with_clinician_id, lambda { |clinician_id|
                              joins(:clinician_addresses).where(clinician_addresses: { clinician_id: clinician_id })
                            }
  scope :with_zip_codes, lambda { |postal_code|
                           joins(:clinician_addresses).where(clinician_addresses: { postal_code: postal_code })
                         }

  scope :with_available_date, ->(available_date) { where("date(available_date) = ?", available_date) }

  scope :with_type_of_care_availability, ->(type_of_care) { where(type_of_care: type_of_care) }

  scope :availabilities_before_time, ->(time) { where("appointment_start_time::time < ?", time.strftime("%H:%M")) }

  scope :availabilities_after_time, ->(time) { where("appointment_start_time::time > ?", time.strftime("%H:%M")) }

  scope :availabilities_till_date, ->(date) { where("appointment_start_time < ?", date + 1.minute) }

  scope :availability_between_time, lambda { |from_time, to_time|
                                      where("appointment_start_time::time BETWEEN ?::time AND ?::time", from_time.strftime("%H:%M"), to_time.strftime("%H:%M"))
                                    }

  scope :with_modality_availabilities, -> { where("in_person_visit = ? OR virtual_or_video_visit = ?", 1, 1) }

  scope :with_in_office_availabilities, -> { where(in_person_visit: 1) }

  scope :with_virtual_visit_availabilities, -> { where(virtual_or_video_visit: 1) }

  scope :with_active_office_keys, lambda {
    joins("LEFT JOIN license_keys on clinician_availability.license_key = license_keys.key").where({ license_keys: { active: true } })
  }

  scope :new_patient_clinician_availabilities, -> { where(is_ia: 1) }

  scope :existing_patient_clinician_availabilities, -> { where(is_fu: 1) }

  scope :get_availabilities, -> (office_key, facility_id, type_of_cares, appointment_start_time) {
    where( "license_key =?  and facility_id = ? and type_of_care =? and appointment_start_time > ?", office_key, facility_id, type_of_cares, appointment_start_time)
  }

  def self.active_data(hours, office_key, facility_id, type_of_cares)
    # if we have a 48hr blockout
    #   if booking at 11am on Friday, first availability will be 11am Tuesday
    #   if booking at 5pm on Friday, first availability will be 5pm Tuesday
    #   if booking at 11am on Saturday, first availability will be 6am Wednesday
    #   if booking at 11am on Sunday, first availability will be 6am Wednesday
    #   if booking at 11am on Monday, first availability will be 11am Wednesday

    holiday_list = ClinicianAvailability.holidays(office_key)

    # when booking an appointment on sat OR sun before a monday holiday first appt should be wednesday; without a holiday first appt should be Tuesday. Basically weekend should behave as friday
    if %w[Sat Sun].include?(Time.now.utc.strftime('%a'))
      hours = hours-24
    end

    # hours is blockout hours for each license key, this is never null, as we are going to have a record for each license key in blockout rules table.
    if hours
      days_to_skip = ClinicianAvailability.days_to_skip(hours)
      holidays_to_skip = ClinicianAvailability.holidays_to_skip((hours + (days_to_skip*24)), holiday_list, office_key, facility_id, type_of_cares)
      block_out_hours = hours + (days_to_skip*24) + (holidays_to_skip*24)
    else
      day_of_the_week = Time.now.utc.strftime("%a")
      multiplier = BUSINESS_DAYS[day_of_the_week].to_i
      block_out_hours = AVAILABILITY_BLOCK_OUT_DEFAULT * multiplier
    end

    appointment_start_time = ClinicianAvailability.calculated_start_time + block_out_hours.hours

    # Clinician availability status in production will have a lot of records. For CSR, we need to check only records that are in future, so looking for any records that are greater than the current date, so we can exclude the records from clinician_availability
    exclude_clinician_availability_list = ClinicianAvailabilityStatus.where("available_date::date >= current_date").map(&:clinician_availability_key)
    exclude_clinician_availability_list = [0] if exclude_clinician_availability_list.empty? # postgres always converts an empty array to NULL. And when filtered with NULL in predicate(where clause), query returns NO results and we will not have any CSR data.

    if holiday_list.size > 0
      where("appointment_start_time > ? and appointment_start_time::date NOT IN (?) and clinician_availability_key NOT IN (?)", appointment_start_time, holiday_list, exclude_clinician_availability_list)
    else
      where("appointment_start_time > ? and clinician_availability_key NOT IN (?)", appointment_start_time, exclude_clinician_availability_list)
    end
  end

  def self.block_out_hours(license_key)
    LicenseKeyRule.block_out_hours_for_license_key(license_key)
  end

  # Returns number of days to skip for the current day of the week, to account for non-business days
  def self.days_to_skip(hours = nil)
    days_to_skip = 0
    target_date_adjusted_for_passed_in_hours = Time.now.utc + hours.hours
    date_range = Time.new.utc.to_date..target_date_adjusted_for_passed_in_hours.to_date
  
    date_range.each do |date|
      
      day_of_the_week = date.strftime('%a') 
      
      if day_of_the_week == "Sat"
        days_to_skip = 2
        break
      end
      days_to_skip = 1 if day_of_the_week == "Sun"
    end

    days_to_skip
  end

  def self.holidays_to_skip(hours_to_skip, holiday_list, office_key, facility_id, type_of_cares)
    target_date = Time.now.utc + hours_to_skip.hours
    date_range = Time.new.utc.to_date..target_date.to_date

    holidays_to_skip_plus_weekend = (date_range.to_a & holiday_list).size
    is_appt_available = 0

    if holidays_to_skip_plus_weekend ==0
      appointment_start_time = ClinicianAvailability.calculated_start_time + (hours_to_skip + holidays_to_skip_plus_weekend*24).hours
      is_appt_available = ClinicianAvailability.get_availabilities(office_key, facility_id, type_of_cares, appointment_start_time).size
    end

    if is_appt_available == 0
      # we are going to check next 4 days, as the best possible scenario is friday and monday being a holiday
      new_target_date = target_date + (4*24).hours
      additional_days_range = target_date.to_date.next_day..new_target_date.to_date

      additional_days_range.each do |each_date|
        if holiday_list.include? each_date
          holidays_to_skip_plus_weekend +=1
        elsif each_date.saturday? || each_date.sunday?
          holidays_to_skip_plus_weekend +=1
        else
          return holidays_to_skip_plus_weekend
        end
      end
    end

    holidays_to_skip_plus_weekend
  end


  def self.calculated_start_time
    day_of_the_week = Time.now.utc.strftime("%a")
    if %w[Sat Sun].include?(day_of_the_week)
      Time.zone.now.beginning_of_day
    else
      Time.zone.now
    end
  end

  def self.search(filters = {})
    clinician_availabilities = active_data(block_out_hours(filters[:license_key]), filters[:license_key], filters[:facility_id], filters[:type_of_cares]).with_active_office_keys.distinct

    clinician_availabilities = clinician_availabilities.with_clinician_id(filters[:clinician_id]) if filters[:clinician_id].present?
    # We use the array if we get it, otherwise we use the required supplied facility_id
    clinician_availabilities = if filters[:facility_ids].present?
      clinician_availabilities.with_facility_ids(filters[:facility_ids])
                               elsif filters[:video].present?
      clinician_availabilities.with_virtual_visit_availabilities
                               elsif filters[:facility_id].present?
      clinician_availabilities.with_facility_id(filters[:facility_id])
                               else
      clinician_availabilities
                               end

    clinician_availabilities = clinician_availabilities.with_type_of_care_availability(filters[:type_of_cares]) if filters[:type_of_cares].present?


    if filters[:modality].present? && filters[:modality] == "video_visits"
      clinician_availabilities = clinician_availabilities.with_virtual_visit_availabilities
    elsif filters[:modality].present? && filters[:modality] == "in_office_visits"
      clinician_availabilities = clinician_availabilities.with_in_office_availabilities
    end

    if filters[:patient_status].present? && filters[:patient_status] == "existing"
      clinician_availabilities.existing_patient_clinician_availabilities
    else
      clinician_availabilities.new_patient_clinician_availabilities
    end
  end

  def self.filter_by_availability_time(filters, offset)
    before_time, after_time = ClinicianSearch.availability_time_filters(filters, offset)
    start_time, end_time = ClinicianSearch.get_client_start_end_time(offset)
    offset = offset.to_i
    if before_time.present? && after_time.present?
      availabilities =  availability_between_time(
        before_time.beginning_of_day + offset.minutes,
                          before_time
      )
                        .or(
                          availability_between_time(
                            after_time,
                            after_time.end_of_day
                          )
                        )
    elsif before_time.present?
      if (offset >= 0) && (start_time >= before_time.beginning_of_day)
        availabilities =  availability_between_time(
          before_time.beginning_of_day + offset.minutes,
                            before_time
        )
      elsif offset.negative?
        availabilities =  availability_between_time(
          before_time.beginning_of_day,
                            before_time
        )
                          
      end
    elsif after_time.present?
      if (offset >= 0) && (end_time >= after_time.end_of_day)
        # after_time is not inclusive. So we add 2 minutes to avoid appointments starting at exactly after_time
        availabilities =  availability_between_time(
          after_time,
                            after_time.end_of_day
        )
                          .or(
                            availability_between_time(
                              after_time + 2.minutes,
                              end_time
                            )
                          )
      elsif offset.negative? && (end_time < after_time.end_of_day)
        availabilities =  availability_between_time(
          after_time,
                            end_time
        )
                          .or(
                            availability_between_time(
                              end_time + 2.minutes,
                              after_time.end_of_day
                            )
                          )
      end
    end
    availabilities
  end

  def duration
    ((appointment_end_time - appointment_start_time) / 60).round
  end

  def get_duration_time
    Time.at((appointment_end_time - appointment_start_time)).utc.strftime("%H:%M:%S")
  end

  def self.holidays(license_key)
    state = LicenseKey.find_by(key: license_key)&.state
    HolidaySchedule.holidays(state)&.map(&:date)
  end

end
