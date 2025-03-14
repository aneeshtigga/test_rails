class CreateAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :appointments do |t|
      t.references :address, null: false, foreign_key: true
      t.references :clinician, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :modality

      t.timestamps
    end
  end
end
