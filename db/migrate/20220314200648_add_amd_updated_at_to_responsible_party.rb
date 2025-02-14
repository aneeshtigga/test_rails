class AddAmdUpdatedAtToResponsibleParty < ActiveRecord::Migration[6.1]
  def change
    add_column :responsible_parties, :amd_updated_at, :datetime
  end
end
