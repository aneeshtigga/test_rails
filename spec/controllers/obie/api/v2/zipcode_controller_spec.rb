require "rails_helper"

RSpec.describe Obie::Api::V2::ZipcodeController, type: :request do
  describe " GET clinicians count by zip_code " do
    let(:postal_code) { create(:postal_code, state: 'AL') }
    let(:feature_enablement) { create(:feature_enablement) }

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })
    end

    it "returns a 404 for invalid zip code" do
      token_encoded_get("/obie/api/v2/clinician_count_by_zip", params: { address_info: { zip_code: "530001" } }, token: @token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns a 200 for valid zip code" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/obie/api/v2/clinician_count_by_zip", params: params, token: @token)

      expect(response).to have_http_status(:ok)
    end
  end

  describe " GET validate by zip_code " do
    let(:postal_code) { create(:postal_code, state: 'AL') }
    let!(:feature_enablement) { create(:feature_enablement) }

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })
    end

    it "returns a 404 for invalid zip code" do
      token_encoded_get("/obie/api/v2/validate_zip", params: { address_info: { zip_code: "530001" } }, token: @token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns a 200 for valid zip code" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/obie/api/v2/validate_zip", params: params, token: @token)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "validate zip code when disabled for 0bie" do
    let(:postal_code) { create(:postal_code, state: 'AL') }
    let!(:feature_enablement) do
      create(:feature_enablement, is_obie_active: false)
    end

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })
    end

    it "returns a 404 for valid zip code, when is_obie_active flag is false" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/obie/api/v2/validate_zip", params: params, token: @token)

      expect(response).to have_http_status(:not_found)
    end
  end
end
