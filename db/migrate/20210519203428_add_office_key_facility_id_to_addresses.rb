class AddOfficeKeyFacilityIdToAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :office_key, :bigint
    add_column :addresses, :facility_id, :bigint
  end
end
