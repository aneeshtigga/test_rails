class RenameExpertiseToConcernPatientDisorders < ActiveRecord::Migration[6.1]
  def change
    rename_column :patient_disorders, :expertise_id, :concern_id
  end
end
