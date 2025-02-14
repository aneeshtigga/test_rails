module Api
  module V1
    class SsoClinicianController < ApplicationController
      skip_before_action :verify_jwt_token

      def modalities
        render json: { message: "Session expired" }, status: :unauthorized and return unless authenticated?
        render json: { message: "clinician not found" }, status: :not_found and return if clinician.blank?

        render json: { modalities: supported_modalities }, status: :ok and return
      end

      def locations
        render json: { message: "Session expired" }, status: :unauthorized and return unless authenticated?
        render json: { message: "clinician not found" }, status: :not_found and return if clinician.blank?
        clinician_offices = patient_id.present?? clinician_offices_by_distance.uniq : clinician_locations.uniq

        render json: { locations: ActiveModelSerializers::SerializableResource.new(
          clinician_offices,
          each_serializer: SsoClinicianLocationSerializer,
          patient_location: patient_location,
        ) }, status: :ok and return
      end

      private

      def selected_patient_id
        session[:selected_patient_id]
      end

      def authenticated?
        !selected_patient_id.nil?
      end

      def permitted_params
        params.permit(:id, :patient_id)
      end

      def patient_id
        permitted_params[:patient_id]
      end

      def client
        @client ||= Amd::AmdClient.new(office_code: session[:license_key])
      end

      def clinician
        @clinician ||= Clinician.find_by(id: permitted_params[:id])
      end

      def availabilities
        availabilities = ClinicianAvailability.active_data(block_out_hours, clinician.license_key, clinician.clinician_addresses.first.facility_id, '').existing_patient_clinician_availabilities
        availabilities = availabilities.where(provider_id: clinician.provider_id,
                                              license_key: clinician.license_key)
        availabilities.pluck(:virtual_or_video_visit, :in_person_visit)
      end

      def supported_modalities
        modalities = []
        availabilities.each do |video_visits, in_office_only|
          break if modalities.include?("video_visits") && modalities.include?("in_office_only")

          modalities.push("video_visits") if video_visits == 1 && modalities.exclude?("video_visits")
          modalities.push("in_office_only") if in_office_only == 1 && modalities.exclude?("in_office_only")
        end
        modalities
      end

      def clinician_locations
        clinician.clinician_addresses.with_clinician_availability.existing_patient_clinician_availabilities
      end

      def patient
        @patient ||= Patient.find_by(amd_patient_id: patient_id)
      end

      def patient_location
        if patient.present?
          location = patient.patient_location
        else
          location = client.patients.get_demographics(patient_id)&.location || ""
        end
        results = RadarApi.geocode(location)
        coordinates = results["addresses"][0]
        return [ coordinates["latitude"], coordinates["longitude"] ]
      end

      def clinician_offices_by_distance
        clinician_locations.by_distance(:origin=> patient_location).uniq
      end

      def block_out_hours
        LicenseKeyRule.block_out_hours_for_license_key(clinician.license_key)
      end
    end
  end
end
