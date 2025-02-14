class RemoveColumnToCarrierInsurance < ActiveRecord::Migration[6.1]
  def change
    remove_column :carrier_insurances, :carrier_category, :string
    remove_column :carrier_insurances, :create_timestamp, :datetime
    remove_column :carrier_insurances, :change_timestamp, :datetime
  end
end
