class CreateResponsibleParties < ActiveRecord::Migration[6.1]
  def change
    create_table :responsible_parties do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :date_of_birth, null: false
      t.string :gender, null: false

      t.timestamps
    end
  end
end
