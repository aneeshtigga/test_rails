class CreateApiRequestResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :api_request_responses do |t|
      t.json :payload, default: {}
      t.json :response, default: {}
      t.json :headers, default: {}
      t.string :url
      t.datetime :time

      t.timestamps
    end
  end
end
