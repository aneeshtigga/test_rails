module Api
  module V1
    class AppointmentCancellationsController < ApplicationController
      include PatientAppointmentHelper

      def update
        @appointment_occured_past_flag = @patient_appointment.appointment_occurred_in_past?
        
        return appointment_already_occured_in_past_response if @appointment_occured_past_flag

        return appointment_already_cancelled_response if @patient_appointment.cancelled?

        @cancellable = @patient_appointment.is_cancellable?

        return appointment_not_cancellable_response unless @cancellable

        response = update_amd_service

        if response.present? && response["updated"]
          @patient_appointment.update!(status: :cancelled)
          appointment_successfully_cancelled_response
        else
          appointment_cancellation_failed_response
        end
      end
    end
  end
end
