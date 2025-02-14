class RemoveColumnsOfFacilityAcceptedInsurance < ActiveRecord::Migration[6.1]
  def change
    remove_column :facility_accepted_insurances, :facility_id
    remove_column :facility_accepted_insurances, :provider_id
    remove_column :facility_accepted_insurances, :license_key
  end
end
