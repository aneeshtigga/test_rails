require "tmpdir"
require "fileutils"

class InsuranceCardUploadService
  def initialize(insurance_coverage, params = {})
    @insurance_coverage = insurance_coverage
    @params = params
  end

  def save
    if @params[:front_card].present?
      blob_id = save_file_to_s3("front_card")
      SaveInsuranceCardWorker.perform_async(@insurance_coverage.id, "front_card", blob_id, @params[:booked_by])
    end
    if @params[:back_card].present?
      blob_id = save_file_to_s3("back_card")
      SaveInsuranceCardWorker.perform_async(@insurance_coverage.id, "back_card", blob_id, @params[:booked_by])
    end
  end

  private

  def save_file_to_s3(file)
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(@params[file.to_sym].read),
      filename: "patient_#{@insurance_coverage.patient_id}_#{file}.jpeg"
    ).id
  end
end
