class AddCboLicenseKeyToPatientAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :patient_appointments, :cbo, :integer
    add_column :patient_appointments, :license_key, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
        UPDATE patient_appointments 
        SET cbo = clinicians.cbo, license_key  = clinicians.license_key
        FROM clinicians WHERE patient_appointments.license_key IS NULL AND patient_appointments.clinician_id = clinicians.id
        SQL
      end
    end
  end


end
