class AddFacilityNameToAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :facility_name, :string
  end
end
