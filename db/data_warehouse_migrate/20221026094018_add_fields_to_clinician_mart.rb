class AddFieldsToClinicianMart < ActiveRecord::Migration[6.1]
  def change
    add_column :vw_clinician_mart, :intervention, :string
    add_column :vw_clinician_mart, :population, :string
  end
end
