class CreatePostalCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :postal_codes do |t|
      t.string :zip_code
      t.string :city
      t.string :state
      t.string :country
      t.string :country_code
      t.string :state_code
      t.integer :time_zone
      t.float :latitude
      t.float :longitude
      t.string :day_light_saving

      t.timestamps
    end
  end
end
