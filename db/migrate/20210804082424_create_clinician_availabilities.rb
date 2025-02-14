class CreateClinicianAvailabilities < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_availability, if_not_exists: true do |t|
      t.integer :clinician_availability_key
      t.bigint :license_key
      t.integer :profile_id
      t.integer :column_id
      t.integer :provider_id
      t.string :npi
      t.integer :facility_id
      t.datetime :available_date
      t.string :reason
      t.datetime :appointment_start_time
      t.datetime :appointment_end_time
      t.string :type_of_care
      t.integer :virtual_or_video_visit
      t.integer :in_person_visit
      t.integer :rank_most_available
      t.integer :rank_soonest_available
    end
  end
end
