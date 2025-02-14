class RemoveUpdatedAtFromClinicianMart < ActiveRecord::Migration[6.1]
  def change
    remove_column :vw_clinician_mart, :updated_at, :datetime
  end
end
