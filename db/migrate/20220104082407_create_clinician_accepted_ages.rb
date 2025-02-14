class CreateClinicianAcceptedAges < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_accepted_ages do |t|
      t.integer :clinician_id
      t.integer :min_accepted_age
      t.integer :max_accepted_age

      t.timestamps
    end
  end
end
