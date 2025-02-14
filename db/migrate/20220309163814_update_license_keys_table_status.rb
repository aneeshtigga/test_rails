class UpdateLicenseKeysTableStatus < ActiveRecord::Migration[6.1]
  def change
    add_column :license_keys, :status_tmp, :boolean, default: true
    
    LicenseKey.reset_column_information

    LicenseKey.where(status: false).update_all(status_tmp: true)
    LicenseKey.where(status: true).update_all(status_tmp: false)

    rename_column :license_keys, :status_tmp, :active
    remove_column :license_keys, :status
  end
end
