class AddCboFieldToClinicianAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :clinician_addresses, :cbo, :integer
  end
end
