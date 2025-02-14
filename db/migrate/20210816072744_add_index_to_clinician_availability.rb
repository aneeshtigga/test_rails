class AddIndexToClinicianAvailability < ActiveRecord::Migration[6.1]
  def change
    add_index :clinician_availability, :facility_id
    add_index :clinician_availability, :provider_id
    add_index :clinician_availability, :license_key
  end
end
