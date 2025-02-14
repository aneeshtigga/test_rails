class CreateCarrierInsurances < ActiveRecord::Migration[6.1]
  def change
    create_table :carrier_insurances do |t|
      t.bigint :license_key
      t.bigint :clinician_id
      t.bigint :facility_id
      t.bigint :npi
      t.string :carriers_category
 
      t.datetime :create_timestamp
      t.datetime :change_timestamp
    end
  end
end
