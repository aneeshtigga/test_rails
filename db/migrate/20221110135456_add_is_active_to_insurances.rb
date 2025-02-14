class AddIsActiveToInsurances < ActiveRecord::Migration[6.1]
  def change
    add_column :insurances, :is_active, :boolean, default: true
  end
end
