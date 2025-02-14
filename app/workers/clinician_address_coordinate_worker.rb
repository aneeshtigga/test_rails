class ClinicianAddressCoordinateWorker
  include Sidekiq::Worker
  sidekiq_options queue: :clinician_address_coordinate_worker_queue, retry: true

  def perform(id)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    clinician_address = ClinicianAddress.find_by(id: id)
    raise "Clinician address with id: #{id} not found" if clinician_address.nil?

    if clinician_address.latitude.blank? && clinician_address.longitude.blank?
      audit_data = clinician_address.update_coordinates_data 
      status = :completed
    end
  rescue StandardError => e
    ErrorLogger.report(e)
    raise(e)
  ensure
    AuditJob.create!({
    job_name: "ClinicianAddressCoordinateWorker", 
    params: { id: id },
    audit_data: audit_data,
    start_time: start_time,
    end_time: DateTime.now.utc,
    status: status,
    })
  end
end
