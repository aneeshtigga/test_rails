class AddColumnToInsurance < ActiveRecord::Migration[6.1]
  def change
    add_column :insurances, :mds_carrier_id, :integer
    add_column :insurances, :mds_carrier_name, :string
    add_column :insurances, :amd_carrier_id, :integer
    add_column :insurances, :amd_carrier_name, :string
    add_column :insurances, :amd_carrier_code, :string
    add_column :insurances, :license_key, :string
    add_column :insurances, :amd_is_active, :boolean, default: true
  end
end
