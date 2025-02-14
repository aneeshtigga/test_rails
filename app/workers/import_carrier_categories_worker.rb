class ImportCarrierCategoriesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :import_carrier_categories_worker_queue, retry: 1

  def perform
    start_time = DateTime.now.utc
    audit_data = {}
    status = :failed

    begin
      new_insurance_count = 0
      array = []
      CarrierInsurance.in_batches.each  do |batch|
        batch.each do |carrier_insurance|
          insurance_data = {
            name: carrier_insurance[:mds_carrier_name],
            mds_carrier_id: carrier_insurance[:mds_carrier_id],
            mds_carrier_name: carrier_insurance[:mds_carrier_name],
            amd_carrier_id: carrier_insurance[:amd_carrier_id],
            amd_carrier_name: carrier_insurance[:amd_carrier_name],
            amd_carrier_code: carrier_insurance[:amd_carrier_code],
            license_key: carrier_insurance[:license_key],
            amd_is_active: carrier_insurance[:amd_is_active],
          }
          update_data = {
            obie_external_display: carrier_insurance[:obie_external_display],
            abie_intake_internal_display: carrier_insurance[:abie_intake_internal_display],
            website_display: carrier_insurance[:website_display],
            enrollment_effective_from: carrier_insurance[:enrollment_effective_from]
          }

          associate_facilities_to_insurance_params = {
            facility_id: carrier_insurance.facility_id,
            amd_carrier_id: carrier_insurance.amd_carrier_id,
            mds_carrier_name: carrier_insurance.mds_carrier_name,
            office_key: carrier_insurance.license_key,
            clinician_id: carrier_insurance.clinician_id,
            supervisors_name: carrier_insurance.supervisors_name,
            license_number: carrier_insurance.license_number
          }

          insurance = Insurance.where(insurance_data).first
          updated_insurance = Insurance.where(insurance_data).update(update_data)
          unless insurance
            insurance = Insurance.create!(insurance_data.merge(update_data))
            new_insurance_count += 1 # used for audit
          end
          array << insurance.id

          AssociateFacilitiesToInsuranceWorker.perform_async(associate_facilities_to_insurance_params)
        end
      end
      array = array.uniq.compact

      # metrics for audit table
      activated_insurance_count = Insurance.unscoped.where(id: array, amd_is_active: false).count
      deactivated_insurance_count = Insurance.unscoped.where.not(id: array, amd_is_active: true).count

      Insurance.unscoped.where(id: array).update_all(amd_is_active: true)
      Insurance.unscoped.where.not(id: array).update_all(amd_is_active: false)

      inactive_clinician_ids = Clinician.unscoped.where.not(deleted_at: nil).pluck(:id)
      inactive_clinician_address_ids = ClinicianAddress.unscoped.where.not(deleted_at: nil).ids


      FacilityAcceptedInsurance.unscoped.where.not(insurance_id: array).update_all(active: false)
      FacilityAcceptedInsurance.unscoped.where(clinician_id: inactive_clinician_ids).update_all(active: false)
      FacilityAcceptedInsurance.unscoped.where(clinician_address_id: inactive_clinician_address_ids).update_all(active: false)

      audit_data = {
        activated_insurance_count: activated_insurance_count,
        deactivated_insurance_count: deactivated_insurance_count,
        new_insurance_count: new_insurance_count,
      }

      status = :completed
    ensure
      AuditJob.create!({
                         job_name: "ImportCarrierCategoriesWorker",
                         params: {},
                         audit_data: audit_data,
                         start_time: start_time,
                         end_time: DateTime.now.utc,
                         status: status,
                       })
    end
  end
end