class AddAmdUpdatedAtToInsuranceCoverage < ActiveRecord::Migration[6.1]
  def change
    add_column :insurance_coverages, :amd_updated_at, :datetime
  end
end
