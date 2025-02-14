class CreateClinicianLicenseTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :clinician_license_types do |t|
      t.integer :clinician_id
      t.integer :license_type_id

      t.timestamps
    end
    add_index(:clinician_license_types, :clinician_id)
    add_index(:clinician_license_types, :license_type_id)
  end
end
