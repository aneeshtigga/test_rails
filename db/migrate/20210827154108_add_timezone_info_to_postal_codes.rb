class AddTimezoneInfoToPostalCodes < ActiveRecord::Migration[6.1]
  def change
    remove_column :postal_codes, :time_zone, :integer
    add_column :postal_codes, :time_zone, :string
    add_column :postal_codes, :time_zone_abbr, :string
    add_column :postal_codes, :utc_offset_sec, :bigint
  end
end