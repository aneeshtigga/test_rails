class AddSupervisoryFieldsToCarrierInsurance < ActiveRecord::Migration[6.1]
  def change
    add_column :carrier_insurances, :supervisors_name, :string
    add_column :carrier_insurances, :license_number, :string
  end
end
