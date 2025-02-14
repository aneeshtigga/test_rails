class CreateAccountHolders < ActiveRecord::Migration[6.1]
  def change
    create_table :account_holders do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :date_of_birth, null: false
      t.string :gender, null: false
      t.string :phone_number
      t.string :source
      t.boolean :receive_email_updates, default: false
      t.boolean :email_verification_sent, default: false
      t.jsonb :search_filter_values, default: {}
      t.boolean :email_verified, default: false

      t.timestamps
    end
  end
end
