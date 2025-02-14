require "rails_helper"

RSpec.describe Abie::Api::V2::ZipcodeController, type: :request do
  describe " GET validate by zip_code " do
    let(:postal_code) { create(:postal_code, state: 'AL') }
    let!(:feature_enablement) { create(:feature_enablement) }

    before do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
    end

    it "returns a 404 for invalid zip code" do
      token_encoded_get("/abie/api/v2/validate_zip", params: { address_info: { zip_code: "530001" } }, token: @token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns a 200 for valid zip code" do
      create(:clinician_address, postal_code: "99950")

      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/abie/api/v2/validate_zip", params: params, token: @token)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "validate zip code when its a non lifestance state" do
    let(:postal_code) { create(:postal_code, state: 'AL') }
    let!(:feature_enablement) do
      create(:feature_enablement, lifestance_state: false)
    end

    before do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
    end

    it "returns a 404 for valid zip code, when lifestance_state is false" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/abie/api/v2/validate_zip", params: params, token: @token)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "validate zip code when disabled for abie" do
    let(:postal_code) { create(:postal_code, state: 'AL') }
    let!(:feature_enablement) do
      create(:feature_enablement, is_abie_active: false)
    end

    before do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
    end

    it "returns a 404 for valid zip code, when is_abie_active flag is false" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/abie/api/v2/validate_zip", params: params, token: @token)

      expect(response).to have_http_status(:not_found)
    end
  end
end
