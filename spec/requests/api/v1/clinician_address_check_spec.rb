require "rails_helper"

RSpec.describe "Api::V1::ClinicianAddressCheck", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:clinician1) { create(:clinician) }
  let!(:clinician2) { create(:clinician, :with_address) }

  describe "GET /api/v1/clinician_health_check" do

    it "returns clinician with no address" do
      token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
      token_encoded_get("/api/v1/clinician_address_check", params: nil, token: token)

      expect(response).to have_http_status(:success)
      expect(json_response["clinician_ids"]).to eq([clinician1.id])
      expect(json_response["clinician_count"]).to eq(1)
    end
  end
end
