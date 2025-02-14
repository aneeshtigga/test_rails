class CreateInsuranceCoverages < ActiveRecord::Migration[6.1]
  def change
    create_table :insurance_coverages do |t|
      t.string :company_name, null: false
      t.string :member_id, null: false
      t.string :group_id, null: false
      t.string :relation_to_policy_holder
      t.references :policy_holder, null: false, foreign_key: { to_table: :people }

      t.timestamps
    end
  end
end
