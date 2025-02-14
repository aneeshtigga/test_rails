class CreateHipaaRelationshipCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :hipaa_relationship_codes do |t|
      t.integer :code
      t.string :description
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
