require "rails_helper"

RSpec.describe "Api::V1::Insurance", type: :request do
  describe "GET /index" do
    let!(:postal_code) { create(:postal_code) }
    let!(:address) { create(:clinician_address, postal_code: postal_code.zip_code, state: postal_code.state) }
    let!(:insurance) { create(:insurance, name: "Anthem") }
    let!(:insurance2) { create(:insurance, name: "Humana", abie_intake_internal_display: true, obie_external_display: false) }
    let!(:facility_accepted_insurance) { create(:facility_accepted_insurance, insurance: insurance, clinician_address: address) }
    let!(:facility_accepted_insurance2) { create(:facility_accepted_insurance, insurance: insurance2, clinician_address: address) }
    let(:care) { create(:type_of_care, facility_id: address.facility_id, amd_license_key: address.office_key, clinician_id: address.clinician_id) }
    let!(:availability) do
      create(:clinician_availability, appointment_start_time: (Time.now.utc + 1.week), license_key: address.office_key, provider_id: address.provider_id,
                                        facility_id: address.facility_id)
    end

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })

      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token2 = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
    end

    it "returns a 404 for invalid zip code" do
      token_encoded_get("/api/v1/insurances", params: { zip_code: "530001", app_name: "obie" }, token: @token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns supported insurances with active new patient availabilities" do
      params = { zip_code: postal_code.zip_code, type_of_care: care.type_of_care, app_name: "obie" }
      token_encoded_get("/api/v1/insurances", params: params, token: @token)

      expect(json_response["insurances"]).to include(insurance.name)
      expect(response).to have_http_status(:ok)
    end
    
    it "returns distinct insurances" do
      address2 = create(:clinician_address, postal_code: postal_code.zip_code)
      address_with_insurance = create(:clinician_address, postal_code: postal_code.zip_code)
      dup_insurance = create(:facility_accepted_insurance, insurance: insurance, clinician_address: address2)
      address_2_availability = create(:clinician_availability,
                                      appointment_start_time: (Time.now.utc + 1.week),
                                      license_key: address2.office_key,
                                      provider_id: address2.provider_id,
                                      facility_id: address2.facility_id)

      params = { zip_code: postal_code.zip_code, app_name: "obie" }
      token_encoded_get("/api/v1/insurances", params: params, token: @token)

      expect(json_response["insurances"]).to match([insurance.name, "I don’t see my insurance"])
      expect(response).to have_http_status(:ok)
    end

    context "when app_name is abie" do
      let!(:params) { { zip_code: postal_code.zip_code, type_of_care: care.type_of_care, app_name: "abie" } }
      it "returns insurances with abie_intake_internal_display true" do
        token_encoded_get("/api/v1/insurances", params: params, token: @token2)

        expect(json_response["insurances"]).to include(insurance2.name)
      end

      it "does not return insurances with abie_intake_internal_display false" do
        token_encoded_get("/api/v1/insurances", params: params, token: @token2)

        expect(json_response["insurances"]).not_to include(insurance.name)
      end
    end

    context "when app_name is obie" do
      let!(:params) { { zip_code: postal_code.zip_code, type_of_care: care.type_of_care, app_name: "obie" } }

      it "returns insurances with obie_external_display true" do
        token_encoded_get("/api/v1/insurances", params: params, token: @token)

        expect(json_response["insurances"]).to include(insurance.name)
      end

      it "does not return insurances with obie_external_display false" do
        token_encoded_get("/api/v1/insurances", params: params, token: @token)

        expect(json_response["insurances"]).not_to include(insurance2.name)
      end
    end
        
    it "should not return insurances with only existing patient availability" do
      availability.update(reason: "TELE", is_ia: 0)
      params = { zip_code: postal_code.zip_code, type_of_care: "Test", app_name: "obie" }
      token_encoded_get("/api/v1/insurances", params: params, token: @token)

      expect(json_response["insurances"]).not_to include(insurance.name)
      expect(response).to have_http_status(:ok)
    end

    it "returns a 401 status if jwt token not passed" do
      token_encoded_get("/api/v1/insurances", params: { app_name: "obie" })

      expect(response).to have_http_status(:unauthorized)
      expect(json_response["message"]).to eq("Jwt token expired or invalid")
    end
  end
end
