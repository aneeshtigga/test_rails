require "rails_helper"

RSpec.describe Obie::Api::V2::CliniciansController, type: :request do
  describe " GET clinicians" do
    let!(:postal_code) { create(:postal_code) }
    let!(:token) { JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name }) }
    let!(:params) do
      { age: 23, type_of_cares: "Adult Therapy", zip_codes: "99950", utc_offset: "360", payment_type: "insurance" }
    end

    it "returns a 422 unprocessable entity when missing required params" do
      invalid_params = { age: 23, type_of_cares: "Adult Therapy", payment_type: "insurance", utc_offset: "360" }

      token_encoded_get("/obie/api/v2/clinicians", params: invalid_params, token: token)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a 422 unprocessable entity when invalid params are passed" do
      invalid_params = {
        age: 23, distance: 60, type_of_cares: "Adult Therapy", zip_codes: "530001", payment_type: "insurance", utc_offset: "360"
      }
      token_encoded_get("/obie/api/v2/clinicians", params: invalid_params, token: token)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a 200 for valid params" do
      token_encoded_get("/obie/api/v2/clinicians", params: params, token: token)

      expect(response).to have_http_status(:ok)
    end

    it "has a valid schema" do
      token_encoded_get("/obie/api/v2/clinicians", params: params, token: token)

      expect(response).to match_response_schema("obie/api/v2/clinicians")
    end

  end

  describe " GET clinician by id" do
    let!(:postal_code) { create(:postal_code) }
    let!(:clinician) { create(:clinician, :with_address) }
    let!(:type_of_care) { create(:type_of_care, clinician: clinician) }
    let!(:clinician2) { create(:clinician, :with_address, first_name: 'other', last_name: 'provider') }
    let!(:token) { JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name }) }

    it "returns a 401 status if jwt is not passed" do
      token_encoded_get("/obie/api/v2/clinician/#{clinician.id}", params: {}, token: nil)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns a 200, when optional param app_name is not passed" do
      token_encoded_get("/obie/api/v2/clinician/#{clinician.id}", token: token)

      expect(response).to have_http_status(:ok)
    end

    it "returns a 200, when optional param app_name is passed" do
      token_encoded_get("/obie/api/v2/clinician/#{clinician.id}", params: { app_name: 'obie' }, token: token)

      expect(response).to have_http_status(:ok)
    end

    it "returns status not found, when an invalid clinician is passed as param" do
      clinician = rand(100)
      token_encoded_get("/obie/api/v2/clinician/#{clinician}", params: { app_name: 'obie' }, token: token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 200, when we request other_providers" do
      params = {other_providers: true}
      token_encoded_get("/obie/api/v2/clinician/#{clinician2.id}", params: params, token: token)

      expect(response).to have_http_status(:ok)
    end
  end
end
