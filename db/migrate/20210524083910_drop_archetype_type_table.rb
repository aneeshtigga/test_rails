class DropArchetypeTypeTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :archetype_types
  end
end
