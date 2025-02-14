class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :address_line1, null: false
      t.string :address_line2
      t.string :address_line3
      t.string :address_line4
      t.string :city, null: false
      t.string :state, null: false
      t.string :postal_code
      t.string :last_name, null: false
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
