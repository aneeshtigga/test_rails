class CreateLicenseTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :license_types do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index(:license_types, :name)
  end
end
