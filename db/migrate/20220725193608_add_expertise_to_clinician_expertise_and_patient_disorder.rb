class AddExpertiseToClinicianExpertiseAndPatientDisorder < ActiveRecord::Migration[6.1]
  def change
    rename_column :clinician_expertises, :speciality_id, :expertise_id
    rename_column :patient_disorders, :speciality_id, :expertise_id
  end
end
