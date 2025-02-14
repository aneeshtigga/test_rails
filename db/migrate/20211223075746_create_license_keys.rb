class CreateLicenseKeys < ActiveRecord::Migration[6.1]
  def change
    create_table :license_keys do |t|
      t.bigint :key
      t.integer :status

      t.timestamps
    end
  end
end
