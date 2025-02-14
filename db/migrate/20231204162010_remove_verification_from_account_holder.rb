class RemoveVerificationFromAccountHolder < ActiveRecord::Migration[6.1]
  def change
    remove_column :account_holders, :verification_email, if_exists: true
  end
end
