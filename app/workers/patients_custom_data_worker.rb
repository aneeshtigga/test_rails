class PatientsCustomDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: :patients_custom_data_worker_queue, retry: 1 

  def perform(patient_id)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    if (patient = Patient.find_by(id: patient_id))
      PatientCustomDataObieService.new(patient_id).post_pronouns_data
      if patient&.emergency_contact && patient&.emergency_contact&.amd_instance_id.blank?
        PatientCustomDataPtContactService.new(patient_id).post_data
      else
        PatientCustomDataPtContactService.new(patient_id).update_data
      end
    end

    status = :completed
  rescue StandardError => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                       job_name: "PatientsCustomDataWorker",
                       params: {patient_id: patient_id},
                       audit_data: audit_data,
                       start_time: start_time,
                       end_time: DateTime.now.utc,
                       status: status,
                     })
  end
end
