# Preview all emails at http://localhost:3000/rails/mailers/patient_hold_appointment
class PatientHoldAppointmentPreview < ActionMailer::Preview
  def hold_appointment
    PatientHoldAppointmentMailer.with(patient_appointment: PatientAppointment.first).hold_appointment
  end
end
