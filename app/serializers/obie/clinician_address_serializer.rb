# == Schema Information
# Schema version: 20230330105145
#
# Table name: clinician_addresses
#
#  id               :bigint           not null, primary key
#  address_code     :string
#  address_line1    :string           not null
#  address_line2    :string
#  apt_suite        :string
#  area_code        :string
#  cbo              :integer
#  city             :string           not null
#  country_code     :string
#  deleted_at       :datetime         indexed, indexed => [postal_code]
#  facility_name    :string
#  latitude         :float            indexed
#  longitude        :float            indexed
#  office_key       :bigint           indexed => [provider_id, facility_id]
#  postal_code      :string           indexed, indexed => [deleted_at]
#  primary_location :boolean          default(TRUE)
#  state            :string           not null, indexed
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  clinician_id     :bigint           not null, indexed
#  facility_id      :bigint           indexed => [provider_id, office_key]
#  provider_id      :bigint           indexed => [facility_id, office_key]
#
# Indexes
#
#  index_clinician_addresses_on_clinician_id                (clinician_id)
#  index_clinician_addresses_on_deleted_at                  (deleted_at)
#  index_clinician_addresses_on_latitude                    (latitude)
#  index_clinician_addresses_on_longitude                   (longitude)
#  index_clinician_addresses_on_pid_fid_lk                  (provider_id,facility_id,office_key)
#  index_clinician_addresses_on_postal_code                 (postal_code)
#  index_clinician_addresses_on_postal_code_and_deleted_at  (postal_code,deleted_at)
#  index_clinician_addresses_on_state                       (state)
#
# Foreign Keys
#
#  fk_rails_...  (clinician_id => clinicians.id)
module Obie
  class ClinicianAddressSerializer < ActiveModel::Serializer
    attributes :id, :address_line1, :address_line2, :city, :state, :postal_code, :address_code, :office_key, :facility_id, :distance_in_miles
    attributes :facility_name, :primary_location, :apt_suite, :area_code, :country_code, :clinician_availabilities
    attributes :insurances, :video_visit, :in_office, :supervised_insurances, :license_key, :license_type
    attributes :rank_most_available, :rank_soonest_available

    has_many :clinician_availabilities, serializer: ClinicianAvailabilitySerializer

    def insurances
      insurances = object.insurances.pluck(:id, :name).uniq
      # Id name key value pair to front end
      keys = %w[id name]
      insurances.map { |v| keys.zip v }.map(&:to_h)
    end

    def license_type
      object.clinician.license_type
    end

    def supervised_insurances
      insurances = object.insurances.where.not(facility_accepted_insurances: { supervisors_name: nil }).pluck(:id, :name).uniq
      # Id name key value pair to front end
      keys = %w[id name]
      insurances.map { |v| keys.zip v }.map(&:to_h)
    end

    def video_visit
      object.clinician.video_visit
    end

    def in_office
      object.clinician.in_office
    end

    def clinician_availabilities
      clinician_availabilities = object.clinician_availabilities.with_active_office_keys
      clinician_availabilities = if @instance_options[:patient_status].present? && @instance_options[:patient_status] == "existing"
                                   clinician_availabilities.existing_patient_clinician_availabilities
                                 else
                                   clinician_availabilities.new_patient_clinician_availabilities
                                 end
      if @instance_options[:type_of_cares].present?
        clinician_availabilities = clinician_availabilities.with_type_of_care_availability(@instance_options[:type_of_cares])
      end
      clinician_availabilities.active_data(block_out_hours, object.license_key, object.facility_id,
                                           @instance_options[:type_of_cares]).order("appointment_start_time").first(3)
    end

    def distance_in_miles
      if @instance_options[:postal_code].present?
        ClinicianAddress.distance_between_two_points(
          [@instance_options[:postal_code]&.as_json&.fetch("latitude").to_f,
           @instance_options[:postal_code]&.as_json&.fetch("longitude").to_f], [object.latitude.to_f, object.longitude.to_f]
        )
      end
    end

    def block_out_hours
      LicenseKeyRule.block_out_hours_for_license_key(object.license_key)
    end

    def rank_most_available
      object.clinician_availabilities.first&.rank_most_available || RANK_MOST_AVAILABLE
    end

    def rank_soonest_available
      object.clinician_availabilities.first&.rank_soonest_available || RANK_SOONEST_AVAILABLE
    end
  end
end

