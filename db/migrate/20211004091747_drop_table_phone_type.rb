class DropTablePhoneType < ActiveRecord::Migration[6.1]
  def change
    drop_table(:phone_types, if_exists: true)
  end
end
