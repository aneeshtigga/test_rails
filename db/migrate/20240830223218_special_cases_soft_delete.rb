class SpecialCasesSoftDelete < ActiveRecord::Migration[6.1]
  def change
    add_column :special_cases, :deleted_at, :datetime
    add_index :special_cases, :deleted_at

    SpecialCase.find_by(name: "Currently experiencing suicidal thoughts")&.soft_delete!
  end
end
