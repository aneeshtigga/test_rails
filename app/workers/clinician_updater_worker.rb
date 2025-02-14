class ClinicianUpdaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_updater_worker_queue, retry: false

  def perform(provider_id, license_key)
    begin
      start_time = DateTime.now.utc
      audit_data = {}
      status = :failed

      audit_data = ClinicianUpdater.add_or_update_clinician(provider_id: provider_id, license_key: license_key)
      status = :completed

    rescue StandardError => e
      ErrorLogger.report(e)
      raise e
    ensure
      AuditJob.create!({
                         job_name: "ClinicianUpdaterWorker",
                         params: {provider_id: provider_id, license_key: license_key},
                         audit_data: audit_data,
                         start_time: start_time,
                         end_time: DateTime.now.utc,
                         status: status,
                       })
    end
  end
end
