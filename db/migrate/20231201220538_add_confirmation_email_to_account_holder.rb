class AddConfirmationEmailToAccountHolder < ActiveRecord::Migration[6.1]
  def change
    add_column :account_holders, :confirmation_email, :string  
  end
end
