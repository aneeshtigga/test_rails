class DropTableRelation < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :relations, column: :party1_id   if foreign_key_exists?(:relations, column: :party1_id)
    remove_foreign_key :relations, column: :party2_id   if foreign_key_exists?(:relations, column: :party2_id)
    remove_index :relations, :index_relations_on_party1_id, if_exists: true
    remove_index :relations, :index_relations_on_party2_id, if_exists: true
    drop_table(:relations, if_exists: true)
  end
end
