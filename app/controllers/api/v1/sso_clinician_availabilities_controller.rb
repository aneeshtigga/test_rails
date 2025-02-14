module Api
  module V1
    class SsoClinicianAvailabilitiesController < ApplicationController
      skip_before_action :verify_jwt_token

      def index
        render json: { message: "Session expired" }, status: :unauthorized and return unless authenticated?
        render json: { message: "clinician not found" }, status: :not_found and return if clinician.blank?

        @clinician_availability_records = ClinicianAvailability.search(availability_search_params)
        @clinician_availability_dates = @clinician_availability_records.map do |clininician_availability|
          clininician_availability.available_date.to_date
        end.uniq

        if permitted_search_params[:available_date].present?
          @clinician_availability_records = @clinician_availability_records.with_available_date(permitted_search_params[:available_date])
        end
        render json: @clinician_availability_records,
               each_serializer: ClinicianAvailabilitySearchSerializer,
               adapter: :json,
               meta: { clinician_availability_dates: @clinician_availability_dates },
               status: :ok and return
      end

      private

      def selected_patient_id
        session[:selected_patient_id]
      end

      def authenticated?
        !selected_patient_id.nil?
      end

      def permitted_search_params
        params.permit(:facility_id, :clinician_id, :modality, :available_date, :type_of_cares, :patient_status)
      end

      def availability_search_params
        permitted_search_params.merge(:patient_status => "existing")
      end

      def clinician
        @clinician ||= Clinician.find_by(id: permitted_search_params[:clinician_id])
      end
    end
  end
end
