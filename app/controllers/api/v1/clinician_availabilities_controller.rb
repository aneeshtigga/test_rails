module Api
  module V1
    class ClinicianAvailabilitiesController < ApplicationController
      def index
        unless check_permitted_search_params
          render json: { message: check_permitted_params_data },
                 status: :not_found and return
        end

        @clinician_availability_records = ClinicianAvailability.search(permitted_search_params.merge(license_key: license_key))
        @clinician_availability_dates = @clinician_availability_records.map do |clinician_availability|
          clinician_availability.available_date.to_date
        end.uniq

        @clinician_availability_records = @clinician_availability_records.with_available_date(permitted_search_params[:available_date])

        holiday_list = ClinicianAvailability.holidays(license_key)
        render json: @clinician_availability_records,
               each_serializer: ClinicianAvailabilitySearchSerializer,
               adapter: :json,
               meta: { clinician_availability_dates: (@clinician_availability_dates-holiday_list) },
               status: :ok and return
      end

      private

      def permitted_search_params
        params.permit(:facility_id, :clinician_id, :available_date,
                      :type_of_cares, :patient_status, :video, facility_ids: [])
      end

      def check_permitted_search_params
        permitted_search_params.key?(:facility_id) && permitted_search_params.key?(:clinician_id) && permitted_search_params.key?(:available_date) && permitted_search_params.key?(:type_of_cares)
      end

      def check_permitted_params_data
        array = []
        array << "facility_id" unless permitted_search_params.key?(:facility_id)
        array << "clinician_id" unless permitted_search_params.key?(:clinician_id)
        array << "available_date" unless permitted_search_params.key?(:available_date)
        array << "type_of_cares" unless permitted_search_params.key?(:type_of_cares)
        text = "Missing required params #{array.join(',')}"
      end

      def license_key
        Clinician.find_by(id: permitted_search_params[:clinician_id])&.license_key
      end
    end
  end
end
