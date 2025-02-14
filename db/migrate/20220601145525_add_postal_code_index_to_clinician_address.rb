class AddPostalCodeIndexToClinicianAddress < ActiveRecord::Migration[6.1]
  def change
    add_index :clinician_addresses, :postal_code
  end
end
