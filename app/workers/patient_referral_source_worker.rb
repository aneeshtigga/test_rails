class PatientReferralSourceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :patient_referral_source_worker_queue, retry: 5

  def perform(patient_id)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    patient = Patient.find_by(id: patient_id)
    AddMarketingReferralService.new(patient).push_referral if patient.present? && patient.referral_source.present?
    
    status = :completed
  rescue StandardError => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                       job_name: "PatientReferralSourceWorker",
                       params: {patient_id: patient_id},
                       audit_data: audit_data,
                       start_time: start_time,
                       end_time: DateTime.now.utc,
                       status: status,
                     })
  end
end
