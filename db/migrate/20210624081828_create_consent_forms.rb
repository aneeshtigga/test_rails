class CreateConsentForms < ActiveRecord::Migration[6.1]
  def change
    create_table :consent_forms do |t|
      t.text :content, null: false
      t.boolean :active, default: true
      t.string :name, null: false
      t.integer :age_type
      t.string :state_abbreviation
      t.integer :content_type

      t.timestamps
    end
  end
end
