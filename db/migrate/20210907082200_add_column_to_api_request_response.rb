class AddColumnToApiRequestResponse < ActiveRecord::Migration[6.1]
  def change
    add_column :api_request_responses, :api_action, :string
    add_column :api_request_responses, :api_class, :string
    add_column :api_request_responses, :response_code, :string
    add_column :api_request_responses, :response_message, :string
    add_column :api_request_responses, :api_method_call, :string
  end
end
