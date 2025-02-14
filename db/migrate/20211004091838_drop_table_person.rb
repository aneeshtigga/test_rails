class DropTablePerson < ActiveRecord::Migration[6.1]
  def change
    remove_index :people, :index_people_on_amd_id, if_exists: true
    remove_index :people, :index_people_on_uuid, if_exists: true
    drop_table(:people, if_exists: true)
  end
end
