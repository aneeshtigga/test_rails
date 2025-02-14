class CreateEducationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :create_educations_worker_queue, retry: 1

  def perform(npi)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    audit_data = ClinicianEducationSync.create_data(npi)

    status = :completed
  rescue StandardError => e
        ErrorLogger.report(e)
        raise(e)
  ensure
        AuditJob.create!({
        job_name: "CreateEducationsWorker", 
        params: { npi: npi },
        audit_data: audit_data,
        start_time: start_time,
        end_time: DateTime.now.utc,
        status: status,
        })
  end
end
