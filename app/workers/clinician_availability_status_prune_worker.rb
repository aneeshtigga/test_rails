class ClinicianAvailabilityStatusPruneWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_availability_status_prune_worker_queue, retry: false

  def perform
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    count = ClinicianAvailabilityStatus.count

    ActiveRecord::Base.connection.execute("TRUNCATE TABLE clinician_availability_statuses")

    audit_data = { ca_statuses_deleted: count }

    status = :completed
  ensure
    AuditJob.create!({
                        job_name: "ClinicianAvailabilityStatusPruneWorker",
                        params: {},
                        audit_data: audit_data,
                        start_time: start_time,
                        end_time: DateTime.now.utc,
                        status: status
                      })
  end
end
