class CreateTypeOfCaresWorker
  include Sidekiq::Worker
  sidekiq_options queue: :create_type_of_cares_worker_queue, retry: 1

  def perform(clinician_id)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    begin
      audit_data = TypeOfCare.create_data(clinician_id)
      status = :completed
    rescue StandardError => e
      ErrorLogger.report(e)
      raise e
    ensure
      AuditJob.create!({
                          job_name: "CreateTypeOfCaresWorker",
                          params: { clinician_id: clinician_id },
                          audit_data: audit_data,
                          start_time: start_time,
                          end_time: DateTime.now.utc,
                          status: status,
                        })
    end
  end
end
