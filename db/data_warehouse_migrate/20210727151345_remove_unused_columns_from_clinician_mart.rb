class RemoveUnusedColumnsFromClinicianMart < ActiveRecord::Migration[6.1]
  def change
    remove_column :vw_clinician_mart, :accepting_new_patients, :boolean
    remove_column :vw_clinician_mart, :education, :string
  end
end
