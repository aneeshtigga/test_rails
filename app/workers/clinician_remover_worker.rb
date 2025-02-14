class ClinicianRemoverWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_remover_worker_queue, retry: 1

  def perform(provider_id)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    audit_data = Clinician.find_by(provider_id: provider_id)&.soft_delete
    status = :completed
  rescue StandardError => e
      ErrorLogger.report(e)
      raise e
  ensure
      AuditJob.create!({
        job_name: "ClinicianRemoverWorker", 
        params: { provider_id: provider_id},
        audit_data: audit_data,
        start_time: start_time,
        end_time: DateTime.now.utc,
        status: status,
      })
  end
end
