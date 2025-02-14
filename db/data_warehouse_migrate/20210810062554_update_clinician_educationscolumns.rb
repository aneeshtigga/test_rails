class UpdateClinicianEducationscolumns < ActiveRecord::Migration[6.1]
  def change
    add_column :clinician_educations, :universityname, :string, null: false
    add_column :clinician_educations, :universitycity, :string
    add_column :clinician_educations, :universitystate, :string
    add_column :clinician_educations, :universitycountry, :string
    remove_column :clinician_educations, :education, :string
  end
end
