module PatientAppointmentHelper
  extend ActiveSupport::Concern

  included do
    before_action :set_patient_appointment, only: %i[update]
  end

  private

  def set_patient_appointment
    @patient_appointment = PatientAppointment.find_by(id: params[:id])
    if @patient_appointment.nil?
      render json: { message: "Patient Appointment not found" },
             status: :not_found and return
    end
  end

  def update_amd_service
    amd_update_service = AppointmentUpdateService.new(@patient_appointment.appointment_id,
                                                      @patient_appointment.patient)
    amd_update_service.update_appointment
  end

  def appointment_already_occured_in_past_response
    render json: { message: "Appointment already occured in past", already_cancelled_flag: @patient_appointment.cancelled?, cancellable: false, appointment_occured_past_flag: @appointment_occured_past_flag },
           status: :unprocessable_entity
  end

  def appointment_already_cancelled_response
    render json: { message: "Appointment already cancelled", already_cancelled_flag: @patient_appointment.cancelled?, cancellable: false, appointment_occured_past_flag: @appointment_occured_past_flag },
           status: :unprocessable_entity
  end

  def appointment_not_cancellable_response
    render json: { message: "Cancellations are only accepted more than 48 business hours before the appointment.", cancellable: @cancellable, already_cancelled_flag: false, appointment_occured_past_flag: @appointment_occured_past_flag },
           status: :unprocessable_entity
  end

  def appointment_successfully_cancelled_response
    render json: { message: "Appointment cancelled", cancellable: @cancellable, already_cancelled_flag: false, appointment_occured_past_flag: @appointment_occured_past_flag },
           status: :ok
  end

  def appointment_cancellation_failed_response
    render json: { message: "Failed to cancel the appointment", error: response["error"], errorcode: response["errorcode"], cancellable: @cancellable, already_cancelled_flag: false, appointment_occured_past_flag: @appointment_occured_past_flag },
           status: :unprocessable_entity
  end
end
