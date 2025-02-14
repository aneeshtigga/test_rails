class ClinicianAddress < ApplicationRecord
  include Geokit::Mappable
  include SoftDeletable


  alias_attribute :license_key, :office_key
  attribute       :distance_in_miles, :float, default: 0.0


  belongs_to :clinician
  has_many :facility_accepted_insurances
  has_many :insurances, through: :facility_accepted_insurances
  has_many :clinician_availabilities, foreign_key: %i[provider_id license_key facility_id],
                                      primary_key: %i[provider_id office_key facility_id], class_name: "ClinicianAvailability"

  after_commit :create_active_license_keys, on: :create
  after_commit :update_latitude_longitude, on: [:create, :update]

  acts_as_mappable default_units: :miles,
                   default_formula: :sphere,
                   lat_column_name: :latitude,
                   lng_column_name: :longitude

  default_scope { active }

  scope :with_zip_code, ->(zip_code) { where({ postal_code: zip_code }) }

  scope :active, -> { where({ deleted_at: nil }) }

  scope :with_insurances, lambda { |insurances, app_name|
    left_joins(:insurances).where(insurances: { 
      name: insurances,
      "#{ClinicianAddress.app_filter_field(app_name)}": true
    })
  }

  scope :with_facility_ids, ->(facility_ids) { where(facility_id: facility_ids) }

  #########################################
  ## scopes dealing with availability
  #
  
  scope :with_clinician_availability, lambda {
    left_joins(:clinician_availabilities)
      .where("#{ClinicianAvailability.table_name}.clinician_availability_key is NOT NULL")
  }

  scope :with_type_of_care_availability, lambda { |type_of_care|
    joins(:clinician_availabilities)
      .where(
        "#{ClinicianAvailability.table_name}.type_of_care = ?", 
        type_of_care
      )
  }

  scope(:with_active_availability, lambda do
    left_joins(:clinician_availabilities)
    .where(
      "#{ClinicianAvailability.table_name}.appointment_start_time > ?",
      (Time.now.utc + BUSINESS_DAYS[Time.now.utc.strftime("%a")].to_i.days)
    )
  end)

  scope(:before_time_appointment_availability, lambda do |time|
    left_joins(:clinician_availabilities)
    .where(
      "#{ClinicianAvailability.table_name}.appointment_start_time BETWEEN ?::date AND ?::date AND
        (extract('hour' from #{ClinicianAvailability.table_name}.appointment_start_time) < ?)",
      (Time.now.utc + BUSINESS_DAYS[Time.now.utc.strftime("%a")].to_i.days).strftime("%Y-%m-%d"),
      time.strftime("%Y-%m-%d"),
      time.hour
    )
  end)

  scope(:after_time_appointment_availability, lambda do |time|
    left_joins(:clinician_availabilities)
    .where(
      "#{ClinicianAvailability.table_name}.appointment_start_time BETWEEN ?::date AND ?::date AND
       (extract('hour' from #{ClinicianAvailability.table_name}.appointment_start_time) >= ?)",
      (Time.now.utc + BUSINESS_DAYS[Time.now.utc.strftime("%a")].to_i.days).strftime("%Y-%m-%d"),
      time.strftime("%Y-%m-%d"),
      time.hour
    )
  end)

  scope(:availability_between_time, lambda do |from_time, to_time|
    left_joins(:clinician_availabilities)
    .where(
      "#{ClinicianAvailability.table_name}.appointment_start_time::time BETWEEN ?::time AND ?::time",
      from_time.strftime("%H:%M"),
      to_time.strftime("%H:%M")
    )
  end)

  scope :availability_till_date, lambda { |date|
    left_joins(:clinician_availabilities).where("#{ClinicianAvailability.table_name}.appointment_start_time < ?", date + 1.minute)
  }

  scope :with_in_office_availabilities, lambda {
    left_joins(:clinician_availabilities).where("#{ClinicianAvailability.table_name}.in_person_visit = ?", 1)
  }

  scope :with_virtual_visit_availabilities, lambda {
    left_joins(:clinician_availabilities).where("#{ClinicianAvailability.table_name}.virtual_or_video_visit = ?", 1)
  }

  scope(:with_modality_availabilities, lambda do
    left_joins(:clinician_availabilities)
    .where("#{ClinicianAvailability.table_name}.in_person_visit = ? OR #{ClinicianAvailability.table_name}.virtual_or_video_visit = ?", 1, 1)
  end)

  scope :new_patient_clinician_availabilities, lambda {
    left_joins(:clinician_availabilities).where("#{ClinicianAvailability.table_name}.is_ia = ?", 1)
  }

  #
  ## end of availability scopes
  ##########################################################

  scope(:with_office_key, lambda do |license_key|
    where(office_key: license_key)
  end)

  scope :with_active_office_keys, lambda {
    joins("LEFT JOIN license_keys on clinician_addresses.office_key = license_keys.key").where({ license_keys: { active: true } })
  }

  scope :existing_patient_clinician_availabilities, lambda {
    left_joins(:clinician_availabilities).where("#{ClinicianAvailability.table_name}.is_fu = ?", 1)
  }

  scope(:with_care, lambda do |care|
    joins("LEFT JOIN type_of_cares on clinician_addresses.office_key = type_of_cares.amd_license_key
       and clinician_addresses.facility_id = type_of_cares.facility_id and clinician_addresses.clinician_id = type_of_cares.clinician_id")
      .where({ type_of_cares: { type_of_care: care } })
  end)

  scope(:most_available, lambda do
    joins(:clinician_availabilities)
    .where("clinician_availability.is_ia=1 and clinician_availability.clinician_availability_key is not null")
    .select("clinician_availability.rank_most_available")
    .order(Arel.sql("clinician_availability.rank_most_available"))
  end)

  # state is expected to 2 character uppercase
  #
  scope(:within_state, lambda do |state|
    where(state: state)
  end)

  # This scope MUST appear first in any chaining
  # because of its use of the CTE.
  #
  # Returns AREL for clinician addresses within the given
  # distance (miles) of a specific latitude, longitude point
  #
  scope(:include_distance, lambda do |lat, lng|
    with(
      distance_included:
          select("
            *,
            round(
              (
                earth_distance(
                  ll_to_earth(#{lat}, #{lng}),
                  ll_to_earth(latitude, longitude)
                ) / 1609.34     -- convert meters to miles
              )::numeric,
              2
            )     AS distance_in_miles
            ")
    )
    .from("distance_included as clinician_addresses")
  end)

  scope(:within_miles_of, lambda do |miles, lat, lng|
    include_distance(lat, lng)
    .where("clinician_addresses.distance_in_miles <= ?", miles)
  end)

  def self.type_of_care_criteria(care)
    facility_ids = TypeOfCare.with_care(care).pluck(:facility_id).uniq
    with_facility_ids(facility_ids)
  end

  # Uniquely? identify a clinician address to a specific theoretical place
  #
  # The clinician_id is used because of the poor data model.  Instead of
  # using a join table between Clinician and ClinicianAddress
  # where each ClinicianAddress is a unique facility shared
  # by multiple clinicians, a new record is added per clinician.
  #
  def unique_ident
    { 
      cbo:          cbo,         # physical AMD context
      license_key:  license_key, # logical  AMD context
      facility_id:  facility_id, # AMD's ID
      clinician_id: clinician_id # Polaris' ID
    }
  end

  # SMELL: why is this model creating another model instance
  #
  def create_active_license_keys
    LicenseKey.where(key: office_key).first_or_create
  end

  def self.app_filter_field(app_name)
    return "obie_external_display" if app_name == "obie"
    return "abie_intake_internal_display" if app_name == "abie"

    raise "ClinicianAddress.app_filter_field called with unknown app_name: #{app_name}"
  end

  def self.refresh_license_keys
    ClinicianAddress.pluck(:office_key).uniq.each do |key|
      LicenseKey.where(key: key).first_or_create
    end
  end


  # Filter addresses by clinician availability
  # Input:
  #   filters ... an Array of Strings; 
  #               See: ClinicianSearchOptions#availability_filter
  #   offset .... Integer or String that is convertable to an Integer
  #
  # Returns
  #   an AREL
  #
  def self.filter_by_availability_time(filters, offset)
    addresses               = with_active_availability
    before_time, after_time = ClinicianSearch.availability_time_filters(filters, offset)
    start_time, end_time    = ClinicianSearch.get_client_start_end_time(offset)
    offset                  = offset.to_i

    if before_time.present? && after_time.present?
      addresses = if before_time < after_time
        addresses
          .availability_between_time(before_time.beginning_of_day, before_time) 
          .or( 
            addresses
            .availability_between_time(after_time, after_time.end_of_day)
          )
                  # otherwise its an AND condition
                  else 
        addresses
          .availability_between_time(after_time, before_time)         
                  end

    elsif before_time.present?
      if (offset >= 0) && (start_time >= before_time.beginning_of_day)
        addresses = addresses
                    .availability_between_time(before_time.beginning_of_day, before_time)
      
      elsif offset.negative?
        addresses = addresses
                    .availability_between_time(end_time, before_time.end_of_day)
                    .or(
                      addresses
                      .availability_between_time(before_time.beginning_of_day, before_time)
                    )
      end

    elsif after_time.present?
      if (offset >= 0) && (end_time >= after_time.end_of_day)
        addresses = addresses
                    .availability_between_time(after_time, after_time.end_of_day)
                    .or(
                      addresses
                      .availability_between_time(after_time + 2.minutes, end_time)
                    )
      
      elsif offset.negative? && (end_time < after_time.end_of_day)
        addresses = addresses
                    .availability_between_time(after_time, end_time)
                    .or(
                      addresses
                      .availability_between_time(end_time + 2.minutes, after_time.end_of_day)
                    )
      end
    end

    addresses
  end

  def active?
    deleted_at.blank?
  end

  def update_latitude_longitude
    ClinicianAddressCoordinateWorker.perform_async(id) if id.present?     && 
                                                          active?         &&
                                                          latitude.blank? && 
                                                          longitude.blank?
  end

  def self.distance_between_two_points(coordinate1, coordinate2)
    point1 = Geokit::LatLng.new(coordinate1[0], coordinate1[1])
    point2 = Geokit::LatLng.new(coordinate2[0], coordinate2[1])
    point1.distance_to(point2).round(2)
  end

  def update_coordinates_data
    address         = "#{address_line1} #{address_line2} #{city} #{state} #{country_code}".delete("#").squish
    results         = RadarApi.geocode(address)
    coordinates     = results["addresses"][0]

    self.latitude   = coordinates["latitude"]&.to_f&.truncate(LAT_LNG_DECIMAL_PLACES)
    self.longitude  = coordinates["longitude"]&.to_f&.truncate(LAT_LNG_DECIMAL_PLACES)

    save!
  end

  def distance_to_lat_lng(latitude, longitude)
    a_lat_lng = Geokit::LatLng.new(latitude.to_f, longitude.to_f)
    distance_to(a_lat_lng).round(2)
  end
  
  def full_state
    State.find_by(name: state).full_name
  end

  #############################################################
  ## Support for Geokit

  def self.lat_column_name
    "latitude"
  end


  def self.lng_column_name
    "longitude"
  end
end
