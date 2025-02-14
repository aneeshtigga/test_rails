class CreateClinicians < ActiveRecord::Migration[6.1]
  def change
    create_table :clinicians do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :clinician_type, null: false
      t.string :license_type, null: false
      t.text :about_the_provider
      t.boolean :accepting_new_patients, null: false, default: true
      t.boolean :in_office, null: false, default: true
      t.boolean :video_visit, null: false, default: true
      t.boolean :manages_medication, null: false, default: false
      t.string :ages_accepted
      t.string :education
      t.integer :provider_id, null: false
      t.integer :npi, null: false
      t.string :telehealth_url
      t.string :gender

      t.timestamps
    end
  end
end
