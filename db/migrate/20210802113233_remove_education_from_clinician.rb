class RemoveEducationFromClinician < ActiveRecord::Migration[6.1]
  def change
    remove_column :clinicians, :education
  end
end
