class CreateConcerns < ActiveRecord::Migration[6.1]
  def change
    create_table :concerns do |t|
      t.string :name
      t.integer :age_type
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
