# db/migrate/20230327091258_add_indexes_to_license_keys.rb

class AddIndexesToLicenseKeys < ActiveRecord::Migration[6.1]
  def change
    add_index   :license_keys, :cbo, unique: false
    add_index   :license_keys, :key, unique: true
  end
end
