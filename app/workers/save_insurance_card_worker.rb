class SaveInsuranceCardWorker
  include Sidekiq::Worker
  sidekiq_options queue: :save_insurance_card_worker_queue, retry: 1

  def perform(insurance_coverage_id, file_name, blob_id, booked_by = "patient")
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    insurance_coverage = InsuranceCoverage.find_by(id: insurance_coverage_id)
    patient_id = insurance_coverage.patient_id
    optimized_image = file_object(patient_id, file_name, blob_id)
    insurance_coverage.update!("#{file_name}": optimized_image, amd_updated_at: Time.zone.now)
    UploadInsuranceCardWorker.perform_async(insurance_coverage.id, file_name) if booked_by.present? && booked_by == "admin"
    status = :completed
  rescue StandardError => e
    ErrorLogger.report(e)
    raise e
  ensure
    AuditJob.create!({
                       job_name: "SaveInsuranceCardWorker",
                       params: {insurance_coverage_id: insurance_coverage_id, file_name: file_name, blob_id: blob_id, booked_by: booked_by},
                       audit_data: audit_data,
                       start_time: start_time,
                       end_time: DateTime.now.utc,
                       status: status,
                     })
  end

  def file_object(patient_id, file_name, blob_id)
    path = create_temp_file(blob_id)
    begin
      ImageProcessing::MiniMagick.source(path).resize_to_limit(1200, 1200).call(destination: path)
      optimized_image = File.binread(path)
      @file_temp.close(unlink_now = true)
      ActiveStorage::Blob.find_by(id: blob_id).purge

      {
        io: StringIO.new(optimized_image),
        filename: "patient_#{patient_id}_#{file_name}.jpeg",
        content_type: "image/jpeg"
      }
    rescue MiniMagick::Error => e
      ErrorLogger.report(e)
    end
  end

  def create_temp_file(blob_id)
    @file_temp = Tempfile.new(["insurance_#{blob_id}", ".jpeg"])
    @file_temp.binmode
    @file_temp.write(ActiveStorage::Blob.find_by(id: blob_id).download)
    @file_temp.rewind
    path = @file_temp.path
  end
end
