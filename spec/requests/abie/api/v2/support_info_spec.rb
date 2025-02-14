require "rails_helper"

RSpec.describe "support info", type: :request do
  describe "GET /abie/api/v2/support_info" do
      before do
        rsa_private = OpenSSL::PKey::RSA.generate 2048
        rsa_public = rsa_private.public_key

        allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
        @token = JWT.encode({
                              app_displayname: 'ABIE',
                              exp: (Time.now+200).strftime('%s').to_i
                            }, rsa_private, 'RS256')
      end

      let(:support_info) { create(:support_directory) }

      it "returns with 422 un processable entity request when request has no JWT" do
        token_encoded_get("/abie/api/v2/support_info", params: { office_code: "12_345" })

        expect(response).to have_http_status(422)
      end

      it "returns with 404 when support info is missing for requested office_code" do
        token_encoded_get("/abie/api/v2/support_info", params: { office_code: 12_345 }, token: @token)

        expect(response).to have_http_status(404)
      end

      it "returns support information for valid office_code with data" do
        allow_any_instance_of(SupportInfoSerializer).to receive(:heartland_api_key).and_return("abc")
        token_encoded_get("/abie/api/v2/support_info", params: { office_code: support_info.license_key }, token: @token)

        expected_response = [support_info.as_json.merge("heartland_api_key" => "abc", "marketing_referral" => nil)]
        expect(response).to have_http_status(200)
        expect(json_response).to eq(expected_response)
      end

      it "returns an array of support information" do
        support_info2 = create(:support_directory)
        allow_any_instance_of(SupportInfoSerializer).to receive(:heartland_api_key).and_return("abc")
        token_encoded_get("/abie/api/v2/support_info", params: { office_code: support_info.license_key }, token: @token)

        expected_response = [
          support_info2.as_json.merge("heartland_api_key" => "abc", "marketing_referral" => nil),
          support_info.as_json.merge("heartland_api_key" => "abc", "marketing_referral" => nil)
        ]
        expect(response).to have_http_status(200)
        expect(json_response).to eq(expected_response)
      end

      it "returns an array of support information" do
        license_key = create(:license_key)
        rule = create(:rule)
        support_info2 = create(:support_directory, license_key: license_key.key)
        license_key_rule_enable_credit_card = create(:license_key_rule, license_key_id: license_key.id,
                                                     rule_name: rule.key, ruleable_id: rule.id)

        allow_any_instance_of(SupportInfoSerializer).to receive(:heartland_api_key).and_return("abc")
        token_encoded_get("/abie/api/v2/support_info", params: { office_code: support_info2.license_key }, token: @token)

        expected_response = [
          support_info2.as_json.merge("heartland_api_key" => "abc", "marketing_referral" => nil)
        ]
        expect(response).to have_http_status(200)
        expect(json_response).to eq(expected_response)
      end

      it "returns an array of support information with heartland api key as empty" do
        license_key = create(:license_key)
        support_info2 = create(:support_directory, license_key: license_key.key)

        token_encoded_get("/abie/api/v2/support_info", params: { office_code: support_info2.license_key }, token: @token)

        expected_response = [
          support_info2.as_json.merge("heartland_api_key" => "", "marketing_referral" => nil)
        ]
        expect(response).to have_http_status(200)
        expect(json_response).to eq(expected_response)
      end

      it "returns intake_call_in_number as (312) 761-8365" do
        license_key = create(:license_key)
        support_info2 = create(:support_directory, license_key: license_key.key)
        marketing_referral = create(:marketing_referral, display_marketing_referral: "PPP", phone_number: "(312) 761-8365")

        token_encoded_get("/abie/api/v2/support_info", params: { office_code: support_info2.license_key, marketing_referral: "PPP" }, token: @token)

        expected_response = [
          support_info2.as_json.merge("heartland_api_key" => "", "marketing_referral" => marketing_referral.phone_number)
        ]
        expect(response).to have_http_status(200)
        expect(json_response).to eq(expected_response)
      end
  end
end
