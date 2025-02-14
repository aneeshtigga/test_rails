class ChangeClinicianSpecialityToClinicianExpertise < ActiveRecord::Migration[6.1]
  def change
    rename_table :clinician_specialities, :clinician_expertises
  end
end
