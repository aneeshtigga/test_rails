class AddColumnsToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :referring_provider_name, :string
    add_column :patients, :referring_provider_phone_number, :string
  end
end
