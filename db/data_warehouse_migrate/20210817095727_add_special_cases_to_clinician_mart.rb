class AddSpecialCasesToClinicianMart < ActiveRecord::Migration[6.1]
  def change
    add_column :vw_clinician_mart, :special_cases, :string
  end
end
