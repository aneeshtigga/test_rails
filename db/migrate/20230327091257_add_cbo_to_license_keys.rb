# db/migrate/20230327091257_add_cbo_to_license_keys.rb

class AddCboToLicenseKeys < ActiveRecord::Migration[6.1]
  def change
    add_column  :license_keys, :cbo, :bigint, null: true, default: nil,
      comment: "A license key has one and only one CBO; however a CBO can have multiple license keys"
  end
end

