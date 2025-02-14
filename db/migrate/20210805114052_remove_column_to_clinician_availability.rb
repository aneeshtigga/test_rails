class RemoveColumnToClinicianAvailability < ActiveRecord::Migration[6.1]
  def change
    if ActiveRecord::Base.connection.column_exists?(:clinician_availability, :id)
      remove_column :clinician_availability, :id
    end
  end
end
