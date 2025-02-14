class CreateClinicianFocusAreas < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_focus_area do |t|
      t.string :focus_area_name
      t.string :focus_area_type
      t.boolean :is_active
      t.datetime :load_date
      t.timestamps
    end
  end
end
