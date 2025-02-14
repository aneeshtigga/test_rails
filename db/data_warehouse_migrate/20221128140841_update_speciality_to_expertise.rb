class UpdateSpecialityToExpertise < ActiveRecord::Migration[6.1]
  def change
    rename_column :vw_clinician_mart, :speciality, :expertise
  end
end
