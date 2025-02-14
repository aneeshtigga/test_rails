class ImportTypeOfCareWorker
  include Sidekiq::Worker
  sidekiq_options queue: :import_type_of_care_worker_queue, retry: 1

  def perform
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    audit_data = TypeOfCare.import_data
    status = :completed
  rescue StandardError => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                        job_name: "ImportTypeOfCareWorker",
                        params: {},
                        audit_data: audit_data,
                        start_time: start_time,
                        end_time: DateTime.now.utc,
                        status: status,
                       })
  end
end
