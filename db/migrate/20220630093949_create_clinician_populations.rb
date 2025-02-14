class CreateClinicianPopulations < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_populations do |t|
      t.integer :clinician_id
      t.integer :population_id

      t.timestamps
    end
    add_index :clinician_populations, :clinician_id
    add_index :clinician_populations, :population_id
  end
end
