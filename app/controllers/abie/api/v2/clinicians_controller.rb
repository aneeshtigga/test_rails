# app/controllers/abie/api/v2/clinicians_controller.rb

module Abie
  module Api
    module V2
      class CliniciansController < ApplicationController
        before_action :validate_required_params, only: %i[index]

        def index
          clinicians = Abie::V2::CliniciansSearchBuilder.build(permitted_search_params)
          meta = {
            clinician_count: clinicians.count
          }

          render json: {
            clinicians: clinicians,
            meta: meta,
            status: :success
          }
        rescue StandardError => e
          ErrorLogger.report(e)

          render json: { message: "Error fetching clinicians", error: e.message },
                 status: :unprocessable_entity
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
          params[:app_name]='abie' if params[:app_name].blank?

          render({
                   json: clinician, serializer: ClinicianDetailsSerializer, app_name: params[:app_name],
                   type_of_cares: params[:type_of_cares], patient_status: params[:patient_status], postal_code: postal_code,
                   status: :ok
                 })
        end

        def validate_required_params
          required_params = %w[age type_of_cares zip_codes payment_type utc_offset]
          missing_params = required_params - params.keys
          raise 'Missing required params' if missing_params.size.positive?
        rescue StandardError => e
          ErrorLogger.report(e)

          render json: { message: "Error fetching clinicians", error: "#{e.message} - #{missing_params.join(', ')}" },
                 status: :unprocessable_entity
        end

        private

        def postal_code
          zip_code = params[:search].present? && params[:search][:zip_codes].present? ? params[:search][:zip_codes] : params[:zip_codes]
          @postal_code ||= PostalCodeBuilder.build(zip_code)
        end

        def permitted_search_params
          params.permit(
            :age,
            :type_of_cares,
            :zip_codes,
            :payment_type,
            :insurances,
            :special_cases,
            :utc_offset,
            :availability_filter,
            type_of_cares: [],
            zip_codes: [],
            insurances: [],
            special_cases: [],
            availability_filter: []
          ).with_defaults(
            entire_state: true,
            max_clinicians_per_modality: 3
          )
        end
      end
    end
  end
end
