class AddProviderIdToAddress < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :provider_id, :bigint
    add_column :addresses, :deleted_at, :datetime
  end
end
