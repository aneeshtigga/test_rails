class AddCboFieldToClinicianLocationMarts < ActiveRecord::Migration[6.1]
  def change
    add_column :clinician_location_marts, :cbo, :integer
  end
end
