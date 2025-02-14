require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, type: :request do
  describe "generate_token" do
    it "returns a 400 for invalid application_name" do
      post '/api/v1/generate_token', params: { application_name: "" }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 200 for valid application name as params" do
      post '/api/v1/generate_token', params: { application_name: Rails.application.credentials.ols_api_app_name }
      expect(response).to have_http_status(:ok)
    end

    it "returns a 200 for valid amd application name as params" do
      post '/api/v1/generate_token', params: { application_name: Rails.application.credentials.ols_amd_api_app_name }
      expect(response).to have_http_status(:ok)
    end
  end
end
