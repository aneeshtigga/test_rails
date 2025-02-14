class UploadInsuranceCardWorker
  include Sidekiq::Worker
  sidekiq_options queue: :upload_insurance_card_worker_queue, retry: 3

  def perform(insurance_coverage_id, file_name)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    insurance = InsuranceCoverage.find_by(id: insurance_coverage_id)
    if insurance.present?
      patient = insurance.patient
      upload_file_service = patient.client.upload_files
      case file_name
      when "front_card"
        upload_file_service.delete_upload_file(insurance.amd_front_card_view_id) if insurance.amd_front_card_view_id.present?
        if insurance.front_card_url.present?
          front_card = upload_file_service.upload_file(insurance.front_card)
          insurance.update!(amd_front_card_view_id: front_card["@id"])
        end
      when "back_card"
        upload_file_service.delete_upload_file(insurance.amd_back_card_view_id) if insurance.amd_back_card_view_id.present?
        if insurance.back_card_url.present?
          back_card = upload_file_service.upload_file(insurance.back_card)
          insurance.update!(amd_back_card_view_id: back_card["@id"])
        end
      end
    end

    status = :completed
  rescue StandardError => e
      ErrorLogger.report(e)
      raise e
  ensure
      AuditJob.create!({
                         job_name: "UploadInsuranceCardWorker",
                         params: {insurance_coverage_id: insurance_coverage_id, file_name: file_name},
                         audit_data: audit_data,
                         start_time: start_time,
                         end_time: DateTime.now.utc,
                         status: status,
                       })
  end
end
