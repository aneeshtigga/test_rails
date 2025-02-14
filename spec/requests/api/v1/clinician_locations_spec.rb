require "rails_helper"

RSpec.describe "Api::V1::ClinicianLocations", type: :request do
  describe " GET /api/v1/filter_data " do
    let!(:address) { create(:clinician_address, clinician: create(:clinician)) }
    let!(:care) { create(:type_of_care, facility_id: address.facility_id) }
    let!(:insurance) { create(:insurance) }
    let!(:clinician) { create(:clinician) }
    let!(:expertise) { create(:expertise, name: "Depression ") }
    let!(:clinician_expertise) { create(:clinician_expertise, clinician: clinician, expertise: expertise) }
    let!(:special_case) { create(:special_case) }
    let!(:facility_accepted_insurance) do
      create(:facility_accepted_insurance, insurance: insurance, clinician_address: address)
    end

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })
    end

    it "responds with 401 for requests without authorization headers" do
      token_encoded_get("/api/v1/filter_data", params: {}, token: nil)

      expect(response).to have_http_status(:unauthorized)
    end

    it "responds with locations on success" do
      token_encoded_get("/api/v1/filter_data",
                        params: { zip_code: address.postal_code, type_of_care: care.type_of_care, patient_type: "self" }, token: @token)

      expect(response).to have_http_status(:ok)
      expect(json_response).to include("locations")
    end

    it "returns facilities of addresses which offer requested type of care" do
      token_encoded_get("/api/v1/filter_data",
                        params: { type_of_care: care.type_of_care, zip_code: address.postal_code, patient_type: "self" }, token: @token)

      expect(json_response).to include("locations")
      expect(json_response["locations"].first["facility_name"]).to include(address.facility_name)
      expect(json_response["locations"].first["address_line1"]).to include(address.address_line1)
      expect(json_response["locations"].first["city"]).to include(address.city)
      expect(json_response["expertises"].first["name"]).to eq(expertise.name)
      expect(json_response["special_cases"].first["name"]).to eq(special_case.name)
    end

    it "returns facilities of addresses which offers requested insurance" do
      token_encoded_get("/api/v1/filter_data",
                        params: { insurance: insurance.name, type_of_care: care.type_of_care, zip_code: address.postal_code, patient_type: "self" }, token: @token)

      expect(json_response).to include("locations")
      expect(json_response["locations"].first["facility_name"]).to include(address.facility_name)
      expect(address.insurances.first.name).to eq(request["insurance"])
      expect(json_response["expertises"].first["name"]).to eq(expertise.name)
      expect(json_response["special_cases"].first["name"]).to eq(special_case.name)
    end
  end
end
