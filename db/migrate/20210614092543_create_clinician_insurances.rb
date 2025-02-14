class CreateClinicianInsurances < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_insurances do |t|
      t.integer :clinician_id
      t.integer :insurance_id

      t.timestamps
    end
  end
end
