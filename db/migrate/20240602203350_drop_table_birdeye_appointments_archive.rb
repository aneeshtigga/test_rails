class DropTableBirdeyeAppointmentsArchive < ActiveRecord::Migration[6.1]
  def up
    drop_table :birdeye_appointments_archive
  end

  def down
    create_table :birdeye_appointments_archive do |t|
      t.bigint "appointment_id"
      t.string "facility_reference"
      t.string "birdeye_business_id"
      t.string "first_name"
      t.string "last_name"
      t.string "campaign_type"
      t.string "email"
      t.string "phone"
      t.bigint "license_key"
      t.bigint "cbo"
      t.datetime "appointment_date"
      t.datetime "sent_at"
      t.text "error_reason"
      t.text "error_response"
      t.timestamps
    end
  end
end
