class AddActiveToFacilityAcceptedInsurance < ActiveRecord::Migration[6.1]
  def change
    add_column :facility_accepted_insurances, :active, :boolean, default: true
  end
end
