class AddAmdIdToResponsibleParty < ActiveRecord::Migration[6.1]
  def change
    add_column :responsible_parties, :amd_id, :string
  end
end
