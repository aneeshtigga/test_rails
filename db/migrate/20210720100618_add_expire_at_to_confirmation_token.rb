class AddExpireAtToConfirmationToken < ActiveRecord::Migration[6.1]
  def change
    add_column :confirmation_tokens, :expire_at, :datetime
  end
end
