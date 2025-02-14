class CreateLicenseKeyRules < ActiveRecord::Migration[6.1]
  def change
    create_table :license_key_rules do |t|
      t.string :rule_name, index: true
      t.boolean :active, default: true
      t.integer :license_key_id, index: true
      t.string :ruleable_type, index: true
      t.integer :ruleable_id, index: true
      t.timestamps
    end
  end
end
