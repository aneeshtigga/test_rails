require "rails_helper"

RSpec.describe "Api::V1::SelectedSlotInfos", type: :request do
  before :all do
    @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
  end

  describe "GET /show" do
    it "returns 401 for unauthorized request" do
      create(:account_holder)
      token_encoded_get("/api/v1/selected_slot_info", params: {},
                                                      token: nil)

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 if account_holder not found" do
      create(:account_holder)
      token_encoded_get("/api/v1/selected_slot_info", params: { token: "test token" },
                                                      token: @token)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /update" do
    it "returns 401 for unauthorized request" do
      account_holder = create(:account_holder)
      token_encoded_put("/api/v1/account_holders/#{account_holder.id}/selected_slot_info", params: {},
                                                                                           token: nil)

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 if account_holder not found" do
      account_holder = create(:account_holder)
      token_encoded_put("/api/v1/account_holders/#{account_holder.id + 1}/selected_slot_info", params: {},
                                                                                               token: @token)

      expect(response).to have_http_status(:not_found)
    end

    it "updates and returns the selected slot info of account_holder on success" do
      account_holder = create(:account_holder)
      selected_slot_info = { clinician_id: "123", time_slot: "2021-07-27 16:00:00 +0000" }
      token_encoded_put("/api/v1/account_holders/#{account_holder.id}/selected_slot_info",
                        params: { selected_slot_info: selected_slot_info }, token: @token)

      expect(response).to have_http_status(:ok)
      expect(json_response["selected_slot_info"]).to eq(selected_slot_info.as_json)
    end
  end
end
