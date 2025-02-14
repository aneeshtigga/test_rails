class DeleteProviderIdFromTypeOfCare < ActiveRecord::Migration[6.1]
  def up
    remove_column :type_of_cares, :provider_id, :bigint
  end

  def down
    add_column :type_of_cares, :provider_id, :bigint
  end
end
