class AddFacilityAcceptedInsuranceIdToInsuranceCoverage < ActiveRecord::Migration[6.1]
  def change
    add_column :insurance_coverages, :facility_accepted_insurance_id, :integer
  end
end
