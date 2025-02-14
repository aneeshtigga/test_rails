class AddEmailToResponsibleParty < ActiveRecord::Migration[6.1]
  def change
    add_column :responsible_parties, :email, :string, null: false
  end
end
