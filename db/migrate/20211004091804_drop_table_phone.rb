class DropTablePhone < ActiveRecord::Migration[6.1]
  def change
    remove_index :phones, :index_phones_on_contactable, if_exists: true
    drop_table(:phones, if_exists: true)
  end
end
