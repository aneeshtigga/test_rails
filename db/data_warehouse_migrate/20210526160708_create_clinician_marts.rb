class CreateClinicianMarts < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_mart do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :clinician_type, null: false
      t.string :license_type, null: false
      t.string :speciality
      t.text :about_the_provider
      t.boolean :accepting_new_patients
      t.boolean :in_office
      t.boolean :video_visit
      t.boolean :manages_medication
      t.string :ages_accepted
      t.string :education
      t.integer :provider_id, null: false
      t.integer :npi, null: false
      t.integer :license_key
      t.boolean :primary_location
      t.string :location
      t.string :zipcode
      t.string :city
      t.string :state
      t.string :areacode
      t.string :countrycode
      t.integer :cbo
      t.text :telehealth_url
      t.string :gender
      t.string :languages
      t.string :pronouns
      t.timestamps
    end
  end
end
