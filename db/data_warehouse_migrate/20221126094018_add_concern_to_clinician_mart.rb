class AddConcernToClinicianMart < ActiveRecord::Migration[6.1]
  def change
    add_column :vw_clinician_mart, :concern, :string
  end
end
