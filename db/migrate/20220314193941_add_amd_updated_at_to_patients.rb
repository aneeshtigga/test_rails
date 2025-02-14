class AddAmdUpdatedAtToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :amd_updated_at, :datetime
  end
end
