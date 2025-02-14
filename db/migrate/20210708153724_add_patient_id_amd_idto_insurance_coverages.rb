class AddPatientIdAmdIdtoInsuranceCoverages < ActiveRecord::Migration[6.1]
  def change
    add_reference :insurance_coverages, :patient
    add_column :insurance_coverages, :amd_id, :integer
  end
end
