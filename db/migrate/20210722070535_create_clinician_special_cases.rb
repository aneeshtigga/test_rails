class CreateClinicianSpecialCases < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_special_cases do |t|
      t.integer :clinician_id
      t.integer :special_case_id

      t.timestamps
    end
  end
end
