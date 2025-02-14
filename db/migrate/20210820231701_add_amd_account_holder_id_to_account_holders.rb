class AddAmdAccountHolderIdToAccountHolders < ActiveRecord::Migration[6.1]
  def change
    add_column :account_holders, :amd_account_holder_id, :bigint
  end
end
