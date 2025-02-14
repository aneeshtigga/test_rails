class ClinicianLocationDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_location_data_worker_queue, retry: 1

  def perform
    begin
      start_time = DateTime.now.utc
      audit_data = {}
      status = :failed

      audit_data = ClinicianLocationSync.import_data(time_since: 10.days.ago)
      status = :completed
      
    rescue StandardError => e
      ErrorLogger.report(e)
      raise e
    ensure
      AuditJob.create!({
        job_name: "ClinicianLocationDataWorker", 
        params: {},
        audit_data: audit_data,
        start_time: start_time,
        end_time: DateTime.now.utc,
        status: status,
      })
    end
  end
end
