class ConvertLicenseKeyStatusToBoolean < ActiveRecord::Migration[6.1]
  def change
    rename_column :license_keys, :status, :status_tmp
    add_column :license_keys, :status, :boolean, default: false

    LicenseKey.reset_column_information # allow the new column to be available to model methods

    LicenseKey.where(status_tmp: 'active').all.each {|l| l.update_column('status', true)}
    LicenseKey.where(status_tmp: 'in_active').all.each {|l| l.update_column('status', false)}

    remove_column :license_keys, :status_tmp
  end
end
