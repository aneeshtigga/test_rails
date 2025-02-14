class AddAgeTypeToSpecialCase < ActiveRecord::Migration[6.1]
  def change
    add_column :special_cases, :age_type, :integer, default: 2
  end
end
