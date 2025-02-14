class UpdatePatientFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :patients, :applied_filters, :search_filter_values
    add_column :patients, :amd_patient_id, :bigint
    remove_column :patients, :email
  end
end
