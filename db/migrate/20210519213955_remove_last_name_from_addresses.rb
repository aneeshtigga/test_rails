class RemoveLastNameFromAddresses < ActiveRecord::Migration[6.1]
  def change
    remove_column :addresses, :last_name, :string
  end
end
