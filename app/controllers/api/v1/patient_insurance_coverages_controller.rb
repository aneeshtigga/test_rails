module Api
  module V1
    class PatientInsuranceCoveragesController < ApplicationController
      before_action :set_patient, only: %i[update]

      def update 
        insurance_coverages = PatientInsuranceIntakeService.new(
          patient: @patient,
          insurance_params: permitted_params["insurance_details"]
        ).save!
        insurance_coverage = insurance_coverages.last

        render json: { patient: PatientSerializer.new(insurance_coverage.patient) }, status: :ok and return
      rescue StandardError => e
        ErrorLogger.report(e)
        render_error(e)
      end

      private

      def permitted_params
        params.permit(
          :id,
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

      def set_patient
        @patient = Patient.find_by(id: params[:id])

        render json: { message: "Patient not found" }, status: :not_found and return if @patient.nil?
      end
    end
  end
end
