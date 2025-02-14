class AddIndexToClinicianAddress < ActiveRecord::Migration[6.1]
  def change
    add_index :clinician_addresses, [:provider_id, :facility_id, :office_key], name: 'index_clinician_addresses_on_pid_fid_lk'
    add_index :clinician_addresses, :clinician_id
  end
end
