class AddColumnToCarrierInsurance < ActiveRecord::Migration[6.1]
  def change
    add_column :carrier_insurances, :mds_carrier_id, :integer
    add_column :carrier_insurances, :mds_carrier_name, :string
    add_column :carrier_insurances, :amd_carrier_id, :integer
    add_column :carrier_insurances, :amd_carrier_name, :string
    add_column :carrier_insurances, :amd_carrier_code, :string
    add_column :carrier_insurances, :amd_is_active, :boolean, default: true
    add_column :carrier_insurances, :amd_create_timestamp, :datetime
    add_column :carrier_insurances, :amd_change_timestamp, :datetime
  end
end
