class CreateClinicianConcerns < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_concerns do |t|
      t.integer :clinician_id
      t.integer :concern_id

      t.timestamps
    end
    add_index :clinician_concerns, :clinician_id
    add_index :clinician_concerns, :concern_id
  end
end
