class CreateFacilityAcceptedInsurances < ActiveRecord::Migration[6.1]
  def change
    create_table :facility_accepted_insurances do |t|
      t.references :facility, null: false
      t.integer :license_key
      t.integer :insurance_id, null: false

      t.timestamps
    end
  end
end
