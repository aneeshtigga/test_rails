class ImportClinicianMartWorker
  include Sidekiq::Worker
  sidekiq_options queue: :import_clinician_mart_worker_queue, retry: 1

  def perform(*args)
    begin
      start_time = DateTime.now.utc
      audit_data = {}
      status = :failed

      audit_data = ClinicianMartSync.import_data
      status = :completed

    rescue StandardError => e
      ErrorLogger.report(e)
      raise e
    ensure
      AuditJob.create!({
                         job_name: "ImportClinicianMartWorker",
                         params: {},
                         audit_data: audit_data,
                         start_time: start_time,
                         end_time: DateTime.now.utc,
                         status: status,
                       })
    end
  end
end
