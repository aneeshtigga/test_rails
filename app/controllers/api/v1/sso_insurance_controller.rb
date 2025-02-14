module Api
  module V1
    class SsoInsuranceController < ApplicationController
      skip_before_action :verify_jwt_token

      def index
        render json: { message: "Session expired" }, status: :unauthorized and return unless authenticated?
        render json: { message: "patient not found" }, status: :not_found and return if patient.blank?

        render json: { patient_insurances: patients_insurance_info }, status: :ok and return
      end

      private

      def selected_patient_id
        session[:selected_patient_id]
      end

      def authenticated?
        !selected_patient_id.nil?
      end

      def permitted_params
        params.permit(:patient_id)
      end

      def amd_patient_id
        permitted_params[:patient_id]
      end

      def patient
        @patient ||= Patient.find_by(amd_patient_id: amd_patient_id)
      end

      def patients_insurance_info
        patient.client.patients.get_patient_insurance(amd_patient_id).response
      end
    end
  end
end
