module Api
  module V1
    class ResendBookingAppointmentEmailController < ApplicationController
      before_action :set_patient_appointment, only: %i[update]

      def update
        @patient = @patient_appointment.patient
        @account_holder = @patient.account_holder
        raise "Email not provided" if params[:email].blank?
        @patient.update!(email: params[:email]) if (@patient.account_holder_relationship.present? && @patient.account_holder_relationship == "self")
        @account_holder.update!(email: params[:email])
        @account_holder.reload
        PatientAppointmentHoldMailerWorker.perform_async(@patient_appointment.id)
        render json: { account_holder: @account_holder }, status: :ok and return
      rescue ActiveRecord::RecordInvalid, StandardError => e
        render_error(e)
      end

      private

      def render_error(error)
        render json: { message: "Error occured in updating patient email", error: error.message },
                 status: :unprocessable_entity and return
      end

      def set_patient_appointment
        @patient_appointment = PatientAppointment.find_by(id: params[:id])
        if @patient_appointment.blank?
          render json: { message: "Patient Appointment not found" },
                 status: :not_found and return
        end
      end
    end
  end
end
