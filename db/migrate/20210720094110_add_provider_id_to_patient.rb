class AddProviderIdToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :provider_id, :integer
  end
end
