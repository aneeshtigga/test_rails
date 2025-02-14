class ImportClinicianEducationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :import_clinician_educations_worker_queue, retry: 1

  def perform
    begin
      start_time = DateTime.now.utc
      status = :failed

      previous_clinician_education_count = Education.pluck("distinct clinician_id").count
      ClinicianEducationSync.import_data
      status = :completed

    rescue StandardError => e
      ErrorLogger.report(e)
      raise e
    ensure
      AuditJob.create!({
        job_name: "ImportClinicianEducationsWorker",
        params: {},
        audit_data: {
          previous_clinician_education_count: previous_clinician_education_count
        },
        start_time: start_time,
        end_time: DateTime.now.utc,
        status: status
      })
    end
  end
end
