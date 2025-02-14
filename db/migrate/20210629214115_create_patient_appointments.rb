class CreatePatientAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :patient_appointments do |t|
      t.references :clinician, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true
      t.integer :status
      t.text :appointment_note

      t.timestamps
    end
  end
end
