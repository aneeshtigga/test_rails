class UpdateClinicianSpecialCaseWorker
  include Sidekiq::Worker
  sidekiq_options queue: :update_clinician_special_case_worker_queue, retry: 1

  def perform(clinician_id, special_cases)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    audit_data = ClinicianSpecialCaseSync.update_special_cases(clinician_id, special_cases)
    status = :completed
  rescue StandardError => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                       job_name: "UpdateClinicianSpecialCaseWorker",
                       params: {clinician_id: clinician_id, special_cases: special_cases},
                       audit_data: audit_data,
                       start_time: start_time,
                       end_time: DateTime.now.utc,
                       status: status,
                     })
  end
end
