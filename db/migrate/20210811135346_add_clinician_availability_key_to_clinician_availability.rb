class AddClinicianAvailabilityKeyToClinicianAvailability < ActiveRecord::Migration[6.1]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:clinician_availability, :clinician_availability_key)
      add_column :clinician_availability, :clinician_availability_key, :integer 
    end
  end
end
