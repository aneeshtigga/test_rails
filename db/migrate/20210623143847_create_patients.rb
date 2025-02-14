class CreatePatients < ActiveRecord::Migration[6.1]
  def change
    create_table :patients do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :preferred_name
      t.string :email
      t.string :date_of_birth, null: false
      t.string :phone_number
      t.string :referral_source
      t.integer :realtion_with_account_holder, default: 0
      t.string :pronouns
      t.text :about
      t.references :special_case
      t.timestamps
    end
  end
end
