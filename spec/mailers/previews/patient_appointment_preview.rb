# Preview all emails at http://localhost:3000/rails/mailers/patient_appointment
class PatientAppointmentPreview < ActionMailer::Preview
  def appointment_confirmation
    mail = PatientAppointmentMailer.with(patient_appointment: PatientAppointment.first).appointment_confirmation
    Premailer::Rails::Hook.perform(mail)
  end
end
