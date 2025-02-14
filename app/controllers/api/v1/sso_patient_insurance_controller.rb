module Api
  module V1
    class SsoPatientInsuranceController < ApplicationController
      skip_before_action :verify_jwt_token
      skip_before_action :verify_authenticity_token

      def create
        render json: { message: "Session expired" }, status: :unauthorized and return unless authenticated?
        render json: { message: "patient not found" }, status: :not_found and return if patient.blank?

        if permitted_params[:is_changed] == "true"
          insurance_coverages = PatientInsuranceIntakeService.new(
            patient: @patient,
            insurance_params: permitted_params["insurance_details"].merge('is_sso': true)
          ).save!
          insurance_coverage = insurance_coverages.last
          insurance_coverage.create_amd_insurance_data
        end
        render json: { patient: PatientSerializer.new(patient) }, status: :ok and return
      end

      private

      def existing_insurance_coverage
        InsuranceCoverage.find_by(amd_id: permitted_params[:amd_insurance_id])
      end

      def selected_patient_id
        session[:selected_patient_id]
      end

      def authenticated?
        !selected_patient_id.nil?
      end

      def permitted_params
        params.permit(
          :patient_id,
          :is_changed,
          insurance_details:
            [
              :insurance_carrier, :member_id, :mental_health_phone_number, :primary_policy_holder, :provider_id, :license_key, :facility_id,
              { policy_holder: %i[first_name last_name date_of_birth gender email],
                address: %i[address_line1 address_line2 state city postal_code] }
            ]
        )
      end

      def render_error(error)
        render json: { message: "Error occured in saving insurance information", error: error.message },
               status: :unprocessable_entity and return
      end

      def patient
        @patient = Patient.find_by(amd_patient_id: permitted_params[:patient_id])
      end
    end
  end
end
