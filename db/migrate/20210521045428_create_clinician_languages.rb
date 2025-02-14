class CreateClinicianLanguages < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_languages do |t|
      t.references :clinician
      t.references :language
      t.timestamps
    end
  end
end
