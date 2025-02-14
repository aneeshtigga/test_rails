class AptSuiteToAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :apt_suite, :string
    add_column :addresses, :country_code, :string
    add_column :addresses, :area_code, :string
  end
end
