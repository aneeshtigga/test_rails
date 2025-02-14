class AddColumnsPopulationInterventionToPatientDisorders < ActiveRecord::Migration[6.1]
  def change
    add_column :patient_disorders, :population_id, :integer
    add_column :patient_disorders, :intervention_id, :integer
  end
end
