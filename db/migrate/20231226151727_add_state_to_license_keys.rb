class AddStateToLicenseKeys < ActiveRecord::Migration[6.1]
  def change
    add_column :license_keys, :state, :string, comment: "Abbreviated State Code associated with the license key"
  end
end
