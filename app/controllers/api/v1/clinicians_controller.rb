# app/controllers/api/v1/clinicians_controller.rb

require 'pagy/extras/array'

module Api
  module V1
    class CliniciansController < ApplicationController
      def index
        clinicians = Obie::V1::CliniciansSearchBuilder.build(permitted_search_params)

        pagination_data, paginated_clinician_results = pagy_array(clinicians, page: page, items: per_page)

        meta = {
          total_pages: pagination_data.last,
          clinician_count: pagination_data.count,
        }

        render json: {
          clinicians: paginated_clinician_results,
          meta: meta,
          status: :ok
        }
      end

      def show
        clinician = Clinician.active.find_by(id: params[:id])
        return render json: { message: "invalid clinician" }, status: :not_found if clinician.blank?

        if params[:other_providers]
          facilities = clinician.clinician_addresses.map(&:facility_id)
          other_clinicians = Clinician.other_providers(clinician, facilities)

          return render json: other_clinicians,
                 each_serializer: OtherClinicianDetailsSerializer,
                 adapter: :json,
                 status: :ok
        end
        return render json: { message: "app_name is required" }, status: :bad_request if params[:app_name].blank?

        render({
          json: clinician, serializer: ClinicianDetailsSerializer, app_name: params[:app_name],
          type_of_cares: params[:type_of_cares], patient_status: params[:patient_status], postal_code: postal_code,
          status: :ok
        })
      end

      private

      def postal_code
        zip_code = params[:search].present? && params[:search][:zip_codes].present? ? params[:search][:zip_codes] : params[:zip_codes]
        @postal_code ||= PostalCodeBuilder.build(zip_code)
      end

      def page
        @page ||= params[:page].try(:to_i) || 1
      end

      def per_page
        @per_page ||= params[:per_page].try(:to_i) || 10
      end

      def permitted_search_params
        params.fetch(:search, {}).permit(
          :age,
          :app_name,
          :availability_filter,
          :availability_time,
          :clinician_types,
          :concerns,
          :credentials,
          :distance,
          :entire_state,
          :expertises,
          :facility_ids,
          :insurances,
          :interventions,
          :languages,
          :location_names,
          :modality,
          :patient_status,
          :payment_type,
          :populations,
          :pronouns,
          :gender,
          :search_term,
          :sort_order,
          :special_cases,
          :type_of_cares,
          :utc_offset,
          :zip_codes,
          availability_filter: [],
          clinician_types: [],
          concerns: [],
          credentials: [],
          expertises: [],
          facility_ids: [],
          insurances: [],
          interventions: [],
          languages: [],
          license_keys: [],
          location_names: [],
          populations: [],
          pronouns: [],
          gender: [],
          special_cases: [],
          type_of_cares: [],
          zip_codes: []
        )
      end
    end
  end
end
