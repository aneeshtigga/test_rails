class CreateClinicianLocationMarts < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_location_marts do |t|
      t.bigint :license_key
      t.bigint :clinician_id
      t.boolean :primary_location
      t.string :facility_name
      t.bigint :facility_id
      t.string :apt_suite
      t.string :location
      t.string :zip_code
      t.string :city
      t.string :state
      t.string :area_code
      t.string :country_code
      t.integer :is_active

      t.timestamps
    end
  end
end
