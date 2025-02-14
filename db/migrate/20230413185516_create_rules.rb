class CreateRules < ActiveRecord::Migration[6.1]
  def change
    create_table :rules do |t|
      t.string :name
      t.string :data_type
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end
