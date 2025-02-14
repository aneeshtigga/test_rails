class UpdateRelationToAccountHolderOnPatient < ActiveRecord::Migration[6.1]
  def change
    rename_column :patients, :realtion_with_account_holder, :account_holder_relationship
    add_reference :patients, :account_holder, index: true
  end
end
