class RemovePeopleReferenceFromInsuranceCoverages < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :insurance_coverages, column: "policy_holder_id"
  end
end
