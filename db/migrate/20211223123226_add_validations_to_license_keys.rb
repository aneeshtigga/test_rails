class AddValidationsToLicenseKeys < ActiveRecord::Migration[6.1]
  def change
    change_column_default :license_keys, :status, 0
    change_column_null :license_keys, :key, false
  end
end
