class ClinicianLocationUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_location_updater_worker_queue, retry: 1

  def perform(provider_id, office_key, cbo, facility_id)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    ClinicianLocationSync.sync_data(provider_id, office_key, cbo, facility_id)

    status = :completed
  rescue StandardError => e
      ErrorLogger.report(e)
      raise(e)
  ensure
      AuditJob.create!({
      job_name: "ClinicianLocationUpdaterWorker", 
      params: { provider_id: provider_id, office_key: office_key, cbo: cbo, facility_id: facility_id },
      audit_data: audit_data,
      start_time: start_time,
      end_time: DateTime.now.utc,
      status: status,
      })
  end
end
