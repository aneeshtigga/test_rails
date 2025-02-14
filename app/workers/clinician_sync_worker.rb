class ClinicianSyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_sync_worker_queue, retry: false

  def perform
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    ClinicianMart.active.select(:npi, :license_key, :clinician_id).distinct.each do |cm|
      # update postgres records to remove deleted_at timestamp
      Clinician.where(npi: cm.npi, license_key: cm.license_key).update_all(deleted_at: nil)

      # create any records that dont exist in postgres
      unless Clinician.active.find_by(npi: cm.npi, license_key: cm.license_key)
        audit_data = ClinicianUpdater.new(provider_id: cm.clinician_id, license_key: cm.license_key).add_or_update_clinician
      end
    end

    status = :completed
  rescue StandardError => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
      job_name: "ClinicianSyncWorker", 
      params: {},
      audit_data: audit_data,
      start_time: start_time,
      end_time: DateTime.now.utc,
      status: status,
    })
  end
end
