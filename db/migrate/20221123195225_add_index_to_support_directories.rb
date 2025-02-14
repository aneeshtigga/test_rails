class AddIndexToSupportDirectories < ActiveRecord::Migration[6.1]
  def change
    add_index :support_directories, :license_key
  end
end
