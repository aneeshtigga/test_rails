class CreateRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :relations do |t|
      t.references :party1, null: false, foreign_key: { to_table: :people }
      t.references :party2, null: false, foreign_key: { to_table: :people }
      t.string :relationship_code
      t.date :begin
      t.date :ending

      t.timestamps
    end
    add_index :relations, :relationship_code
  end
end
