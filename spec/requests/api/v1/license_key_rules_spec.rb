require "rails_helper"

RSpec.describe "Api::V1::LicenseKeyRules", type: :request do
  describe "GET /index" do
    let!(:insurance_rule_skip_case) { create(:insurance_rule) }
    let!(:insurance_rule_mandatory_case) { create(:insurance_rule, skip_option_flag: false) }
    let!(:license_key) { create(:license_key) }
    let!(:license_key_rule) do
      create(:license_key_rule, license_key: license_key, rule_name: INSURANCE_SKIP_OPTION_RULE, ruleable_type: INSURANCERULE,
                                ruleable_id: insurance_rule_skip_case.id)
    end

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })
    end

    it "returns insurance_skip_option_flag true" do
      token_encoded_get("/api/v1/license_key_rules", params: { license_key: license_key.key }, token: @token)

      expect(json_response["insurance_skip_option_flag"]).to eq(true)
    end

    it "returns insurance_skip_option_flag false" do
      LicenseKeyRule.update(ruleable_type: INSURANCERULE, ruleable_id: insurance_rule_mandatory_case.id) # case where we are setting skip_option_flag false in insurance_rules table
      token_encoded_get("/api/v1/license_key_rules", params: { license_key: license_key.key }, token: @token)

      expect(json_response["insurance_skip_option_flag"]).to eq(false)
    end
  end
end
