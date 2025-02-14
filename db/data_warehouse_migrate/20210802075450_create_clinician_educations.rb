class CreateClinicianEducations < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_educations do |t|
      t.string :education
      t.string :referencetype
      t.string :degree
      t.integer :graduationyear
      t.integer :npi, null: false

      t.timestamps
    end
  end
end
