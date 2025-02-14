class AddColumnToAccountHolder < ActiveRecord::Migration[6.1]
  def change
    add_column :account_holders, :pronouns, :string
    add_column :account_holders, :about, :text
  end
end
