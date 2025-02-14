class AccountHoldersController < ApplicationController
  # NOTE: this is an *appointment* confirmation - not an "account" confirmation
  def send_confirmation_email
    account_holder = AccountHolder.find_by(id: params[:id])

    if account_holder.present? && account_holder.booked_by != 'admin'
      account_holder.update(confirmation_email: params[:email_address])
      patient_appointment = account_holder.patient_appointments.first
      if patient_appointment.blank?
        return render(
          json: {
            message: "Error sending confirmation email",
            error: "Account holder does not have an appointment",
          }, status: :unprocessable_entity
        )
      end

      PatientAppointmentMailer.with(patient_appointment: patient_appointment).appointment_confirmation.deliver_now
      render json: { message: 'Confirmation email sent', email_sent: true }, status: :ok
    else
      messages = []
      messages << 'Account holder does not exist' if account_holder.blank?
      messages << 'Account holder booked_by is an admin' if account_holder&.booked_by == 'admin'
      
      render json: { message: "Error sending confirmation email", error: messages.join(', ') }, status: :unprocessable_entity
    end
  end
end