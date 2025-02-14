class ChangeSpecialityToExpertise < ActiveRecord::Migration[6.1]
  def change
    rename_table :specialities, :expertises
  end
end
