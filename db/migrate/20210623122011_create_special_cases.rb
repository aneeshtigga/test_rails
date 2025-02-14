class CreateSpecialCases < ActiveRecord::Migration[6.1]
  def change
    create_table :special_cases do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
