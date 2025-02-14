class CreateSupportDirectories < ActiveRecord::Migration[6.1]
  def change
    create_table :support_directories do |t|
      t.integer :cbo, null: false
      t.integer :license_key, null: false
      t.string :location
      t.string :intake_call_in_number
      t.string :support_hours
      t.string :established_patients_call_in_number
      t.string :follow_up_url

      t.timestamps
    end
  end
end
