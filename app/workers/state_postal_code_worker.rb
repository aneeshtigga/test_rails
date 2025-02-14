class StatePostalCodeWorker < ApplicationJob
  queue_as :state_postal_code_worker_queue
  retry_on StandardError, wait: 1.minute, attempts: 1

  def perform
    start_time = DateTime.now.utc
    audit_data = {}
    state_postal_code_worker_attempted_count = 0
    status = :failed

    PostalCode.get_states.each_with_index do |state, index|
      # stagger processing of each state by 2 hours
      interval = (index * 2).hours
      StateWorker.set(wait: interval).perform_later(state)
      state_postal_code_worker_attempted_count += 1
    end

    audit_data['state_postal_code_worker_attempted_count'] = state_postal_code_worker_attempted_count
    status = :completed
  rescue StandardError => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                        job_name: "StatePostalCodeWorker",
                        params: {},
                        audit_data: audit_data,
                        start_time: start_time,
                        end_time: DateTime.now.utc,
                        status: status,
                      })
  end
end
