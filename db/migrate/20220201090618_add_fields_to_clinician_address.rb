class AddFieldsToClinicianAddress < ActiveRecord::Migration[6.1]
  def change
    add_column :clinician_addresses, :latitude, :float
    add_column :clinician_addresses, :longitude, :float
  end
end
