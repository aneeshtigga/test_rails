class AddNewColumnsToInsurances < ActiveRecord::Migration[6.1]
  def change
    add_column :insurances, :obie_external_display, :boolean, default: true
    add_column :insurances, :abie_intake_internal_display, :boolean, default: true
    add_column :insurances, :website_display, :boolean, default: true
    add_column :insurances, :enrollment_effective_from, :date
    add_column :insurances, :carrier_name,:string
    add_column :insurances, :carrier_id, :string
  end
end
