class CreatePhoneTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :phone_types do |t|
      t.integer :code
      t.string :description
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
