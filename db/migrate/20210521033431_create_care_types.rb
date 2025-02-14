class CreateCareTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :care_types do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
