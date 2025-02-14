class RenameCarriersCategoryOfCarrierInsurance < ActiveRecord::Migration[6.1]
  def change
    rename_column :carrier_insurances, :carriers_category, :carrier_category
  end
end
