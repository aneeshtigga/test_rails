class AddAmdUpdatedAtToPatientConsent < ActiveRecord::Migration[6.1]
  def change
    add_column :patient_consents, :amd_updated_at, :datetime
  end
end
