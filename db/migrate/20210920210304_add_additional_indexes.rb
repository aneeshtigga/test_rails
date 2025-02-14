class AddAdditionalIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index(:facility_accepted_insurances, [:clinician_address_id, :active], name: :index_facility_insurance_addresses)
    add_index(:clinician_addresses, [:postal_code, :deleted_at])
    add_index(:clinician_special_cases, :clinician_id)
    add_index(:clinician_special_cases, :special_case_id)
  end
end
