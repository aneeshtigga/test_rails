class InsuranceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :insurance_worker_queue, retry: 1

  def perform(patient_id)
      start_time = DateTime.now.utc
      audit_data = {}
      status = :failed

      patient = Patient.find_by(id: patient_id)

      @insurance_coverage = patient.insurance_coverages.last
      if @insurance_coverage.present?
        @insurance_coverage.create_amd_insurance_data if @insurance_coverage.amd_id.blank?
      end
      status = :completed
  rescue StandardError => e
      ErrorLogger.report(e)
      raise e
  ensure
      AuditJob.create!({
                         job_name: "InsuranceWorker",
                         params: { patient_id: patient_id},
                         audit_data: audit_data,
                         start_time: start_time,
                         end_time: DateTime.now.utc,
                         status: status,
                       })
    
  end
end
