class AddIndexOnFacilityAcceptedInsurance < ActiveRecord::Migration[6.1]
  def change
    add_index :facility_accepted_insurances, :clinician_address_id
  end
end
