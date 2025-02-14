class AddUpdatedAtToClinicianMart < ActiveRecord::Migration[6.1]
  def change
    add_column :vw_clinician_mart, :updated_at, :datetime
  end
end
