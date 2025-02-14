class ChangeColumnToClinicianAvailability < ActiveRecord::Migration[6.1]
  def change
    change_column :clinician_availability, :license_key, :bigint
  end
end
