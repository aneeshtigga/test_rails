class RenameAddressToClinicianAddress < ActiveRecord::Migration[6.1]
  def change
    rename_table :addresses, :clinician_addresses
    add_foreign_key :clinician_addresses, :clinicians, column: :clinician_id
  end
end
