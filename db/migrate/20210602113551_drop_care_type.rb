class DropCareType < ActiveRecord::Migration[6.1]
  def change
    drop_table :care_types
  end
end
