class AddProfileIdToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :profile_id, :integer
  end
end
