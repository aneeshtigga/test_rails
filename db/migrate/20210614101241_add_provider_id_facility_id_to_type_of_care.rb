class AddProviderIdFacilityIdToTypeOfCare < ActiveRecord::Migration[6.1]
  def change
    add_column :type_of_cares, :facility_id, :bigint, null: false
    add_column :type_of_cares, :provider_id, :bigint, null: false
  end
end
