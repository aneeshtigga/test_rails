require "rails_helper"

RSpec.describe "Api::V1::Patients", type: :request do
  let!(:skip_patient_amd) { skip_patient_amd_creation }

  before :all do
    @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
  end

  describe "PATCH /api/v1/patient_intake_status/:id" do
    let(:patient) { create(:patient) }

    context "when request is valid" do
      params = { intake_status: "prepare_for_visit" }

      before { token_encoded_patch("/api/v1/patient_intake_status/#{patient.id}", params: params, token: @token) }

      it "returns status code 200" do
        patient.reload
        expect(patient.intake_status).to eq("prepare_for_visit")
        expect(response).to have_http_status(200)
      end
    end

    context "when request is invalid" do
      params = { intake_status: "patient_profile_info" }

      before { token_encoded_patch("/api/v1/patient_intake_status/0", params: params, token: @token) }

      it "returns status code 404" do
        expect(response).to have_http_status :not_found
      end
    end

    context "when token is not passed" do
      params = { intake_status: "patient_profile_info" }

      before { token_encoded_patch("/api/v1/patient_intake_status/#{patient.id}", params: params, token: nil) }

      it "returns status code 401" do
        expect(response).to have_http_status :unauthorized
      end
    end

    context "when wrong intake_status value passed" do
      params = { intake_status: "patient_profile" }

      before { token_encoded_patch("/api/v1/patient_intake_status/#{patient.id}", params: params, token: @token) }

      it "returns status code 422" do
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
