class AddPrimaryLocationToAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :primary_location, :boolean, default: true
  end
end
