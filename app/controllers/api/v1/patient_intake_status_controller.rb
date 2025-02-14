module Api
  module V1
    class PatientIntakeStatusController < ApplicationController
      before_action :set_patient, only: %i[update]

      def update
        @patient.update!(patient_intake_status_param)
        render json: { patient: @patient }, status: :ok and return
      rescue StandardError => e
        ErrorLogger.report(e)
        render_error(e)
      end

      private

      def patient_intake_status_param
        params.permit(:intake_status)
      end

      def set_patient
        @patient = Patient.find_by(id: params[:id])

        render json: { message: "Patient not found" }, status: :not_found and return if @patient.nil?
      end

      def render_error(error)
        render json: { message: "Error occured in saving patient intake information", error: error.message },
               status: :unprocessable_entity and return
      end
    end
  end
end
