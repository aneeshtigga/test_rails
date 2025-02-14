class AddBirdeye < ActiveRecord::Migration[6.1]
  def change
    create_table :birdeye_appointments do |t|
      t.bigint :appointment_id      
      t.string :facility_reference
      t.string :birdeye_business_id
      t.string :first_name
      t.string :last_name
      t.string :campaign_type
      t.string :email
      t.string :phone
      t.bigint :license_key
      t.bigint :cbo
      t.timestamp :appointment_date
      t.timestamp :sent_at
      t.timestamps
    end
  end
end
