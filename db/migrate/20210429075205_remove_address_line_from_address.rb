class RemoveAddressLineFromAddress < ActiveRecord::Migration[6.1]
  def change
    remove_column :addresses, :address_line3, :string
    remove_column :addresses, :address_line4, :string
  end
end
