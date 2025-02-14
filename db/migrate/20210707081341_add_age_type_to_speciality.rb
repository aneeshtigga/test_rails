class AddAgeTypeToSpeciality < ActiveRecord::Migration[6.1]
  def change
    add_column :specialities, :age_type, :integer, default: 2
  end
end
