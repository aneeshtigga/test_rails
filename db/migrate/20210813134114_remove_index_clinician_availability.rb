class RemoveIndexClinicianAvailability < ActiveRecord::Migration[6.1]
  def change
    remove_column :clinician_availability, :index, if_exists: true
  end
end
