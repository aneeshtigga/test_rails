class CreateFeatureEnablements < ActiveRecord::Migration[6.1]
  def change
    create_table :feature_enablements do |t|
      t.string :state, null: false
      t.boolean :is_obie_active, default: true
      t.boolean :is_abie_active, default: true
      t.boolean :lifestance_state, default: true
      t.timestamps
    end
  end
end
