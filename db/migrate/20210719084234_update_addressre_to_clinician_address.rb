class UpdateAddressreToClinicianAddress < ActiveRecord::Migration[6.1]
  def change
    remove_column :appointments, :address_id, :bigint
    add_reference :appointments, :clinician_address, index: true
    
    rename_column :facility_accepted_insurances, :address_id, :clinician_address_id
    add_foreign_key :facility_accepted_insurances, :clinician_addresses, column: :clinician_address_id

    remove_column :patient_appointments, :address_id, :bigint
    add_reference :patient_appointments, :clinician_address, index: true
  end
end
