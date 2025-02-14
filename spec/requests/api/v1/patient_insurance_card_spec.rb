require "rails_helper"

RSpec.describe "Api::V1::PatientInsuranceCards", type: :request do
  describe "POST /api/v1/patient/:id/insurance_card" do
    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end

    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:patient) { create(:patient, amd_patient_id: 5_983_957, marketing_referral_id: 123) }
    let!(:insurance) { create(:insurance) }
    let!(:clinician) { create(:clinician) }
    let!(:address) { create(:clinician_address, clinician: clinician) }
    let!(:facility_accepted_insurance) do
      create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)
    end
    let!(:responsible_party) { create(:responsible_party) }
    let(:insurance_coverage) do
      create(:insurance_coverage, patient: patient, policy_holder: responsible_party, relation_to_policy_holder: "self")
    end
    let(:image1) { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "test1.png")) }
    let(:image2) { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "test2.png")) }
    let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }

    it "returns 401 when token is missing" do
      token_encoded_put("/api/v1/patients/#{patient.id}/insurance_card", params: {}, token: nil)

      expect(response.status).to eq(401)
    end

    it "returns 404 if the patient doesnt have insurance coverage created" do
      token_encoded_put("/api/v1/patients/#{patient.id}/insurance_card", params: {}, token: @token)

      expect(response.status).to eq(404)
      expect(json_response["message"]).to eq("no insurance_coverage found for the patient")
    end

    it "returns 400 if request doesn't have fornt_card or back_card file objects" do
      insurance_coverage
      token_encoded_put("/api/v1/patients/#{patient.id}/insurance_card", params: {}, token: @token)

      expect(response.status).to eq(400)
      expect(json_response["message"]).to eq("Missing file object")
    end

    it "returns 200 if request contains fornt_card or back_card file objects" do
      insurance = insurance_coverage
      token_encoded_put("/api/v1/patients/#{patient.id}/insurance_card", params: { front_card: image1 }, token: @token)

      expect(response.status).to eq(200)
      expect(json_response["message"]).to eq("Successfully uploaded insurance cards")
    end

    it "returns 200 if request includes both front_card and back_card file objects" do
      insurance = insurance_coverage
      token_encoded_put("/api/v1/patients/#{patient.id}/insurance_card",
                        params: { front_card: image1, back_card: image2 }, token: @token)

      expect(response.status).to eq(200)
      expect(json_response["message"]).to eq("Successfully uploaded insurance cards")
    end

    it "returns 422 for request with invalid file object" do
      insurance = insurance_coverage
      token_encoded_put("/api/v1/patients/#{patient.id}/insurance_card",
                        params: { front_card: "file1", back_card: image2 }, token: @token)

      expect(response.status).to eq(422)
      expect(json_response["message"]).to eq("Error occured in saving insurance card")
    end

    it "returns 422 for request with invalid file object" do
      insurance = insurance_coverage
      token_encoded_put("/api/v1/patients/#{patient.id}/insurance_card", params: { front_card: "file1" }, token: @token)

      expect(response.status).to eq(422)
      expect(json_response["message"]).to eq("Error occured in saving insurance card")
    end
  end
end
