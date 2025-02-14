class CreateClinicianCareTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_care_types do |t|
      t.references :clinician
      t.references :care_type
      t.timestamps
    end
  end
end
