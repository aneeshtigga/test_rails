# == Schema Information
# Schema version: 20230220093953
#
# Table name: postal_codes
#
#  id                  :bigint           not null, primary key
#  city                :string
#  country             :string
#  country_code        :string
#  day_light_saving    :string
#  latitude            :float
#  longitude           :float
#  state               :string
#  state_code          :string
#  time_zone           :string
#  time_zone_abbr      :string
#  utc_offset_sec      :bigint
#  zip_code            :string           indexed
#  zip_codes_by_radius :json
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_postal_codes_on_zip_code  (zip_code)
#
class PostalCode < ApplicationRecord
  include Geokit::Mappable
  extend ZipCodeApiService

  RADIUS_DISTANCE = 60
  RADIUS_UNIT = "mile".freeze


  attribute :distance_in_miles, :float


  validates :zip_code, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  scope :get_state, lambda { |zip_code|
    where(zip_code: zip_code).pluck(:state).uniq
  }


  # This scope MUST appear first in any chaining
  # because of its use of the CTE.
  #
  # Returns AREL for clinician addresses within the given
  # distance (miles) of a specific latitude, longitude point
  #
  scope(:within_miles_of, lambda do |miles, lat, lng|
    with(
      distance_included:
          PostalCode.select("
            (
              earth_distance(
                ll_to_earth(#{lat}, #{lng}),
                ll_to_earth(latitude, longitude)
              ) / 1609.34     -- convert meters to miles
            )                 AS distance_in_miles,
            *
            ")
    )
    .from("distance_included as postal_codes")
    .where("distance_in_miles <= ?", miles)
  end)



  def self.get_states
    State.get_all_states
  end

  def self.update_zip_codes(state = "")
    if state.present?
      response = get_zip_codes_by_state(state)

      zip_codes = response["zip_codes"] if response.present?
      if zip_codes.present?
        # process the zip codes in batches of 2,000 to avoid hitting the ZipCodeApi hourly limit
        # after 2,000 zip codes, wait for 1 hour before processing the next batch
        zip_codes.each_slice(2000).with_index do |zip_code_batch, index|
          interval = (index * 1).hours
          zip_code_batch.each do |zip_code|
            ZipCodeWorker.set(wait: interval).perform_later(zip_code)
          end
        end
      end
    end
  end

  def self.create_zip_code(zip_code = "")
    if zip_code.present?
      details = get_zip_code_details(zip_code)
      if details.present?
        postal_code = PostalCode.where(
          zip_code: details["zip_code"]
        ).first_or_create

        lat     = details['lat']&.to_f
        lng     = details['lng']&.to_f

        lat = lat.truncate(LAT_LNG_DECIMAL_PLACES) if lat.present?
        lng = lng.truncate(LAT_LNG_DECIMAL_PLACES) if lng.present?

        postal_code.update(
          city:       details["city"],
          state:      details["state"],
          country:    "US",
          latitude:   lat,
          longitude:  lng,
          time_zone:  details["timezone"]["timezone_identifier"],
          time_zone_abbr:       details["timezone"]["timezone_abbr"],
          utc_offset_sec:       details["timezone"]["utc_offset_sec"],
          day_light_saving:     details["timezone"]["is_dst"]
        )

        zip_codes_by_radius = zip_codes_within_radius_and_state(zip_code)

        postal_code.update(
          zip_codes_by_radius:  zip_codes_by_radius
        )
      end
    end
  end

  # Finds nearby zip codes that are within the same state as a given zip code
  # within a desired radius.
  #
  # Parameters:
  #   zip_code .... An Integer zip_code expected to be within the postal_codes table
  #   radius ...... A Numeric distance in units: miles
  #                 Default value is the constant RADIUS_DISTANCE
  #
  # Returns a Hash with one key whose value is an Array
  # of zip code values.  The key looks something like this:
  #   "60_miles"
  #
  def self.zip_codes_within_radius_and_state(zip_code, radius = RADIUS_DISTANCE)
    home_zip_code = PostalCode.find_by(zip_code: zip_code)

    raise(BadParameterError, "zip code (#{zip_code}) is unknown") if home_zip_code.blank?

    home_state  = home_zip_code.state 

    zip_codes = PostalCode
                .within_miles_of(
                  radius,
                    home_zip_code.latitude,
                    home_zip_code.longitude
                )
                .where.not(zip_code: home_zip_code)
                .where(state: home_state)
                .pluck(:zip_code)

    { "#{radius}_#{RADIUS_UNIT}" => zip_codes }
  end

  def self.get_zip_codes_by_state(state)
    get_zip_code_by_state(state)
  end

  def self.get_zip_code_details(zip_code)
    get_zip_code_degrees(zip_code)
  end

  def nearby_zip_codes
    zip_codes_by_radius["#{RADIUS_DISTANCE}_#{RADIUS_UNIT}"]
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
