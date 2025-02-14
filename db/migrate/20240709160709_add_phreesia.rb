class AddPhreesia < ActiveRecord::Migration[6.1]
  def change
    create_table :phreesia do |t|
      t.integer :license_key, null: false
      t.timestamps
    end
  end
end