class ZipCodeWorker < ApplicationJob
  queue_as :zip_code_worker_queue
  retry_on StandardError, wait: 1.hour, attempts: 1

  def perform(zip_code)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    PostalCode.create_zip_code(zip_code)

    status = :completed
  rescue ZipCodeApiException => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                        job_name: "ZipCodeWorker",
                        params: {},
                        audit_data: audit_data,
                        start_time: start_time,
                        end_time: DateTime.now.utc,
                        status: status,
                      })
  end
end
