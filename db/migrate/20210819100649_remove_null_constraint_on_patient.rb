class RemoveNullConstraintOnPatient < ActiveRecord::Migration[6.1]
  def change
    change_column :patients, :gender, :string, :null => true
  end
end
