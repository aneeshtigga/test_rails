require "rails_helper"

RSpec.describe "Api::V1::AppointmentHealthChecks", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:skip_patient_amd) { skip_patient_amd_creation }

  describe "GET /api/v1/appointment_health_checks" do
    let!(:patient_appointment) do
      create(:patient_appointment)
    end

    it "returns a success" do
      travel_to Time.zone.local(2022, 11, 24, 16, 00, 00) do
        patient_appt =  create(:patient_appointment)
        token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })

        token_encoded_get("/api/v1/appointment_health_checks", params: nil, token: token)

        expect(response).to have_http_status(:success)
        expect(json_response["success"]).to eq(true)
        expect(json_response["threshold"]).to be 3
      end
    end
  end
end
