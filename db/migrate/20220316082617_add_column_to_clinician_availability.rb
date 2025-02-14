class AddColumnToClinicianAvailability < ActiveRecord::Migration[6.1]
  def change
    add_column :clinician_availability, :is_ia, :bigint, default: 1 unless ActiveRecord::Base.connection.column_exists?(:clinician_availability, :is_ia)
    add_column :clinician_availability, :is_fu, :bigint, default: 1 unless ActiveRecord::Base.connection.column_exists?(:clinician_availability, :is_fu)
  end
end
