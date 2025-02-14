module Api
  module V1
    class PatientInsuranceCardController < ApplicationController
      before_action :set_patient, only: %i[update]
      before_action :set_insurance_coverage, only: %i[update]

      def update
        if permitted_params[:front_card].present? || permitted_params[:back_card].present?
          upload_status = InsuranceCardUploadService.new(@insurance_coverage, permitted_params).save

          render json: { message: "Successfully uploaded insurance cards" },
                 status: :ok and return
        else
          render json: { message: "Missing file object" }, status: :bad_request
        end
      rescue StandardError => e
        ErrorLogger.report(e)
        render_error(e)
      end

      private

      def permitted_params
        params.permit(:id, :front_card, :back_card, :booked_by)
      end

      def set_patient
        @patient = Patient.find_by(id: params[:id])

        render json: { message: "Patient not found" }, status: :not_found and return if @patient.nil?
      end

      def set_insurance_coverage
        @insurance_coverage = @patient.insurance_coverages.last

        if @insurance_coverage.nil?
          render json: { message: "no insurance_coverage found for the patient" },
                 status: :not_found and return
        end
      end

      def render_error(error)
        render json: { message: "Error occured in saving insurance card", error: error.message },
               status: :unprocessable_entity and return
      end
    end
  end
end
