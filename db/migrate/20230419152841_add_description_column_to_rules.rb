class AddDescriptionColumnToRules < ActiveRecord::Migration[6.1]
  def change
    add_column :rules, :description, :string, null: true
  end
end
