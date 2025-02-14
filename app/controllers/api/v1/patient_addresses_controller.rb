module Api
  module V1
    class PatientAddressesController < ApplicationController
      before_action :set_patient, only: %i[update]

      def update
        if @patient.intake_address.present?
          @patient.intake_address.update!(intake_address_params)
        else
          intake_address = IntakeAddress.new(intake_address_params)
          @patient.intake_address = intake_address
          @patient.intake_address.save!
        end
        render json: { message: "Intake address successfully added to patient" }, status: :ok and return
      rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => e
        render_error(e)
      end

      private

      def intake_address_params
        params.permit(:address_line1,
                      :address_line2,
                      :city,
                      :state,
                      :postal_code)
      end

      def set_patient
        @patient = Patient.find_by(id: params[:id])

        render json: { message: "Patient not found" }, status: :not_found and return if @patient.nil?
      end

      def render_error(error)
        render json: { message: "Error occured in saving patient address information", error: error.message },
               status: :unprocessable_entity and return
      end
    end
  end
end
