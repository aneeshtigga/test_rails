class AddAddressCodeToAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :address_code, :string
  end
end
