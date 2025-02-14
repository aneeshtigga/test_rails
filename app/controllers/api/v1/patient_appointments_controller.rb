module Api
  module V1
    class PatientAppointmentsController < ApplicationController
      before_action :set_patient_appointment, only: %i[show]

      def show
        if @patient_appointment.present?
          render json: { patient_appointment: PatientAppointmentSerializer.new(@patient_appointment) }, status: :ok and return
        end

        render json: { message: "Patient Appointment not found" }, status: :not_found and return
      end

      private

      def set_patient_appointment
        @patient_appointment = PatientAppointment.find_by(id: params[:id])
      end
    end
  end
end
