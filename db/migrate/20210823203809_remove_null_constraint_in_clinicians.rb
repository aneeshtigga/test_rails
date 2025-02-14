class RemoveNullConstraintInClinicians < ActiveRecord::Migration[6.1]
  def up
    change_column :clinicians, :clinician_type, :string, null: true
  end

  def down
    change_column :clinicians, :clinician_type, :string, null: false
  end
end
