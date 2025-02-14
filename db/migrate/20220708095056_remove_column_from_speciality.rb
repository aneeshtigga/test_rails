class RemoveColumnFromSpeciality < ActiveRecord::Migration[6.1]
  def change
    remove_column :specialities, :age_type
  end
end
