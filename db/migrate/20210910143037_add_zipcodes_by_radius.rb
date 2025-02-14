class AddZipcodesByRadius < ActiveRecord::Migration[6.1]
  def change
    add_column :postal_codes, :zip_codes_by_radius, :json, default: {}
  end
end
