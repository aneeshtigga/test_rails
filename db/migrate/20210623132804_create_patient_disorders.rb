class CreatePatientDisorders < ActiveRecord::Migration[6.1]
  def change
    create_table :patient_disorders do |t|
      t.references :speciality
      t.references :patient
      t.timestamps
    end
  end
end
