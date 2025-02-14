class AddTimestampsToClinicianLocationMart < ActiveRecord::Migration[6.1]
  def change
    add_column :clinician_location_marts, :create_timestamp, :datetime
    add_column :clinician_location_marts, :change_timestamp, :datetime
  end
end
