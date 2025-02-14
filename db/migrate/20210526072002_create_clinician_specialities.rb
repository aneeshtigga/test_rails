class CreateClinicianSpecialities < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_specialities do |t|
      t.integer :clinician_id
      t.integer :speciality_id

      t.timestamps
    end
  end
end
