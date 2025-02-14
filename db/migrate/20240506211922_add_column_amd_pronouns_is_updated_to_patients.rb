class AddColumnAmdPronounsIsUpdatedToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :amd_pronouns_updated, :boolean, default: false
  end
end
