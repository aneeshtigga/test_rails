class CreateSsoAudits < ActiveRecord::Migration[6.1]
  def change
    create_table :sso_audits do |t|
      t.string :app_name
      t.string :first_name
      t.string :last_name
      t.string :email
      t.bigint :expiration
      t.timestamps
    end
  end
end
