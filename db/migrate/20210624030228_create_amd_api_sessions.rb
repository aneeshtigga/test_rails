class CreateAmdApiSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :amd_api_sessions do |t|
      t.string :office_code
      t.string :redirect_url
      t.string :token
      t.timestamps
    end
  end
end
