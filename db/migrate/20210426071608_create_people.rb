class CreatePeople < ActiveRecord::Migration[6.1]
  def change
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :preferred_name
      t.string :middle_name
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.date :date_of_death
      t.string :gender_assigned_at_birth, null: false
      t.string :gender_identification
      t.string :uuid
      t.integer :amd_id

      t.timestamps
    end
    add_index :people, :uuid, unique: true
    add_index :people, :amd_id
  end
end
