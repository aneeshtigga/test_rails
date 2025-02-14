require "rails_helper"

RSpec.describe "Api::V1::SsoInsurances", type: :request do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  describe "GET /index" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:address) { create(:clinician_address) }
    let(:patient) { create(:patient, amd_patient_id: "5984602", marketing_referral_id: 123, office_code: 995456) }
    let!(:hippa_relationship) { create(:hipaa_relationship_code, code: 18, description: "Self") }

    it "returns 401 for unauthorised request" do
      get "/api/v1/sso_insurance"

      expect(response).to have_http_status(401)
    end

    it "returns 404 for request with invalid patient_id" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }
      get "/api/v1/sso_insurance"

      expect(response).to have_http_status(:not_found)
    end

    it "returns 200 for request with valid patient_id" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }
      VCR.use_cassette("get_patient_insurance") do
        get "/api/v1/sso_insurance", params: { patient_id: patient.amd_patient_id }

        expect(response).to have_http_status(:ok)
        expect(json_response["patient_insurances"].keys).to include("insurance_details")
      end
    end
  end
end
