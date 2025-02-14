require "rails_helper"

RSpec.describe "Get cancellation reasons list", type: :request do
  describe "GET /api/v1/cancellation_reasons" do
    it "gets all the cancellation reasons" do
      cancellation_reason1 = create(:cancellation_reason, reason: "Schedulling conflict", reason_equivalent: ">45 HRS")
      create(:cancellation_reason, reason: "Other", reason_equivalent: ">45 HRS")

      token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
      token_encoded_get("/api/v1/cancellation_reasons", params: nil, token: token)

      expect(json_response[0]["reason"]).to eq(cancellation_reason1.reason)
      expect(json_response.size).to eq(2)
    end
  end
end


