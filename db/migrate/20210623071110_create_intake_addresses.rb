class CreateIntakeAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :intake_addresses do |t|
      t.string :address_line1, null: false
      t.string :address_line2
      t.string :city, null: false
      t.string :state, null: false
      t.string :postal_code
      t.references :intake_addressable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
