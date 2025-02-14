module Abie
  module V2
    class ClinicianAddressSerializer < Abie::ClinicianAddressSerializer
      attributes :supervised_insurances, :distance_in_miles, :clinician_id, :created_at, :updated_at
      attributes :provider_id, :deleted_at, :cbo, :latitude, :longitude

      def supervised_insurances
        insurances = object.insurances.where.not(facility_accepted_insurances: { supervisors_name: nil }).pluck(:id, :name).uniq
        # Id name key value pair to front end
        keys = %w[id name]
        insurances.map { |v| keys.zip v }.map(&:to_h)
      end
    end
  end
end