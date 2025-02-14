class CreateConfirmationTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :confirmation_tokens do |t|
      t.string :token , index: { unique: true }
      t.bigint :account_holder_id, null: false

      t.timestamps
    end
  end
end
