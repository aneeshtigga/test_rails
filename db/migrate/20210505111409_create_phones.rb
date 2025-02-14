class CreatePhones < ActiveRecord::Migration[6.1]
  def change
    create_table :phones do |t|
      t.string :phone_number, null: false
      t.string :phone_type_code, null: false
      t.references :contactable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
