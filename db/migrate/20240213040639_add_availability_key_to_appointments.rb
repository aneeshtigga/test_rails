class AddAvailabilityKeyToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :clinician_availability_key, :bigint
  end
end
