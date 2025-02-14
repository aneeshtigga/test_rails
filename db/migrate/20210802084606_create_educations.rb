class CreateEducations < ActiveRecord::Migration[6.1]
  def change
    create_table :educations do |t|
      t.string :education, null:false
      t.string :reference_type
      t.integer :graduation_year
      t.string :degree
      t.references :clinician, null: false, foreign_key: true

      t.timestamps
    end
  end
end
