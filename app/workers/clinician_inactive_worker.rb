class ClinicianInactiveWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_inactive_worker_queue, retry: false

  def perform
    begin
      start_time = DateTime.now.utc
      audit_data = {}
      status = :failed

      audit_data = Clinician.mark_inactive
      status = :completed
      
    rescue StandardError => e
      ErrorLogger.report(e)
      raise e
    ensure
      AuditJob.create!({
        job_name: "ClinicianInactiveWorker", 
        params: {},
        audit_data: audit_data,
        start_time: start_time,
        end_time: DateTime.now.utc,
        status: status,
      })
    end
  end
end
