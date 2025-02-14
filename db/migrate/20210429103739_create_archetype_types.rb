class CreateArchetypeTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :archetype_types do |t|
      t.string :type
      t.string :code
      t.string :description
      t.boolean :active, default: true
      t.date :begining
      t.date :ending

      t.timestamps
    end
  end
end
