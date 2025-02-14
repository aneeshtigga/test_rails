class DropClinicianCareType < ActiveRecord::Migration[6.1]
  def change
    drop_table :clinician_care_types
  end
end
