class AddVerificationEmailToAccountHolder < ActiveRecord::Migration[6.1]
  def change
    add_column :account_holders, :verification_email, :string
  end
end
