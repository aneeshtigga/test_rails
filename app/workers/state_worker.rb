class StateWorker < ApplicationJob
  queue_as :state_worker_queue
  retry_on StandardError, wait: 1.hour, attempts: 1

  def perform(state)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    PostalCode.update_zip_codes(state)
    status = :completed
  rescue ZipCodeApiException => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                        job_name: "StateWorker",
                        params: {state: state},
                        audit_data: audit_data,
                        start_time: start_time,
                        end_time: DateTime.now.utc,
                        status: status,
                      })
  end
end
