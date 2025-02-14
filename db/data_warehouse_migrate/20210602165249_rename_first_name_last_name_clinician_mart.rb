class RenameFirstNameLastNameClinicianMart < ActiveRecord::Migration[6.1]
  def change
    rename_column :clinician_mart, :first_name, :firstname
    rename_column :clinician_mart, :last_name, :lastname
  end
end
