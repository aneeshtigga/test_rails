require "rails_helper"

RSpec.describe HealthCheckController, type: :request do
  describe "index" do
    it "returns a 200 if server is up" do
      get "/health-check"
      expect(response).to have_http_status(:ok)
    end
  end
end
