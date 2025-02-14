class AssociateFacilitiesToInsuranceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :associate_facilities_to_insurance_worker_queue, retry: 1

  def perform(params)
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    facility_id = params["facility_id"]
    license_key = params["office_key"]
    clinician_id = params["clinician_id"]
    amd_carrier_id = params["amd_carrier_id"]
    mds_carrier_name = params["mds_carrier_name"]
    supervisors_name = params["supervisors_name"]
    license_number = params["license_number"]

    address = ClinicianAddress.where(facility_id: facility_id, office_key: license_key, provider_id: clinician_id)&.last

    if address.present?
      insurance = Insurance.find_by(name: mds_carrier_name, license_key: license_key, amd_carrier_id: amd_carrier_id)

      raise "Insurance with mds_carrier_name: #{mds_carrier_name}, license_key: #{license_key}, amd_carrier_id: #{amd_carrier_id} does not exist" if insurance.nil?

      audit_data = FacilityAcceptedInsurance.where(insurance_id: insurance.id, clinician_id: address.clinician_id, clinician_address_id: address.id,
                                      supervisors_name: supervisors_name, license_number: license_number).first_or_create
      status = :completed
    end
  rescue StandardError => e
      ErrorLogger.report(e)
      raise(e)
  ensure
      AuditJob.create!({
      job_name: "AssociateFacilitiesToInsuranceWorker", 
      params: { params: params },
      audit_data: audit_data,
      start_time: start_time,
      end_time: DateTime.now.utc,
      status: status,
      })
    
  end
end
