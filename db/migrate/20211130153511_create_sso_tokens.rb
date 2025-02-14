class CreateSsoTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :sso_tokens do |t|
      t.string :token , index: { unique: true }
      t.jsonb :data, default: {}
      t.datetime :expire_at

      t.timestamps
    end
  end
end
