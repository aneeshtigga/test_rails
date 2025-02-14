class AddProvideridToFacilityAcceptedInsurance < ActiveRecord::Migration[6.1]
  def change
    add_column :facility_accepted_insurances, :provider_id, :bigint
    add_column :facility_accepted_insurances, :address_id, :bigint
    add_column :facility_accepted_insurances, :clinician_id, :bigint
  end
end
