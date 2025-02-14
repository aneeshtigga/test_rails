class DeviseCreateUsers < ActiveRecord::Migration[6.1]
  def change
    
    create_table(:users) do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :provider, :null => false, :default => "saml"
      t.string :saml_uid
      t.timestamps
    end

    add_index :users, :email,        unique: true
    add_index :users, :saml_uid,   unique: true
  end
end
