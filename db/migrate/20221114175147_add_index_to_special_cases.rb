class AddIndexToSpecialCases < ActiveRecord::Migration[6.1]
  def change
    add_index :special_cases, :age_type
  end
end
