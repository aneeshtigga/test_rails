class AddAmdFileIdToPatientConsents < ActiveRecord::Migration[6.1]
  def change
    add_column :patient_consents, :amd_file_id, :string
  end
end
