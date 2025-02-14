class CreateClinicianInterventions < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_interventions do |t|
      t.integer :clinician_id
      t.integer :intervention_id

      t.timestamps
    end
    add_index :clinician_interventions, :clinician_id
    add_index :clinician_interventions, :intervention_id
  end
end
