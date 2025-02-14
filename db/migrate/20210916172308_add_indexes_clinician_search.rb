class AddIndexesClinicianSearch < ActiveRecord::Migration[6.1]
  def change
    add_index(:clinicians, :deleted_at)

    add_index(:clinician_specialities, :clinician_id)
    add_index(:clinician_specialities, :speciality_id)

    add_index(:clinician_addresses, :deleted_at)

    add_index(:facility_accepted_insurances, :clinician_id)
    add_index(:facility_accepted_insurances, :insurance_id)
    add_index(:facility_accepted_insurances, :active)

    add_index(:postal_codes, :zip_code)

    add_index(:insurances, :amd_is_active)

    add_index(:mv_clinician_availability, :type_of_care)
    add_index(:mv_clinician_availability, :appointment_start_time)
    add_index(:mv_clinician_availability, [:provider_id, :license_key, :facility_id], name: :index_mv_clinician_availability_ck)
  end
end
