class AddResponsiblePartyIdToAccountHolders < ActiveRecord::Migration[6.1]
  def change
    add_column :account_holders, :responsible_party_id, :integer
  end
end
