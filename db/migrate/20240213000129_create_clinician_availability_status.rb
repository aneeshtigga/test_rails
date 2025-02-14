class CreateClinicianAvailabilityStatus < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_availability_statuses do |t|
      t.bigint :clinician_availability_key, null: false
      t.timestamp :available_date, null: false
      t.integer :status

      t.timestamps
    end
  end
end
