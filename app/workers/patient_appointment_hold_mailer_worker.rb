class PatientAppointmentHoldMailerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :patient_appointment_hold_mailer_worker_queue, retry: 1

  def perform(patient_appointment_id)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed
    
    patient_appointment = PatientAppointment.find_by_id(patient_appointment_id)
    
    PatientHoldAppointmentMailer.with(patient_appointment: patient_appointment).hold_appointment.deliver_now
    status = :completed
  rescue StandardError => e
      ErrorLogger.report(e)
      raise e
  ensure
      AuditJob.create!({
                        job_name: "PatientAppointmentHoldMailerWorker",
                        params: { patient_appointment_id: patient_appointment_id },
                        audit_data: audit_data,
                        start_time: start_time,
                        end_time: DateTime.now.utc,
                        status: status,
                      })
  
  end
end
