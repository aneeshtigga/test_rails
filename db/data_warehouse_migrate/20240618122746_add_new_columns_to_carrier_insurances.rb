class AddNewColumnsToCarrierInsurances < ActiveRecord::Migration[6.1]
  def change
    add_column :carrier_insurances, :obie_external_display, :boolean
    add_column :carrier_insurances, :abie_intake_internal_display, :boolean
    add_column :carrier_insurances, :website_display,:boolean
    add_column :carrier_insurances, :enrollment_effective_from, :date
    add_column :carrier_insurances, :carrier_name,:string
    add_column :carrier_insurances, :carrier_id, :string
  end
end
