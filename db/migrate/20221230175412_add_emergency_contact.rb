class AddEmergencyContact < ActiveRecord::Migration[6.1]
  def change
    create_table :emergency_contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.references :account_holder
      t.integer :relationship_to_patient
      t.timestamps
    end

  end
end
