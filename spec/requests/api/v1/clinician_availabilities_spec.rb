require "rails_helper"

RSpec.describe "Api::V1::ClinicianAvailabilities", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday

  before do
    travel_to stub_time
  end

  after do
    travel_back
  end

  describe " GET /api/v1/clinician_availabilities " do
    let!(:clinician) { create(:clinician) }
    let!(:clinician_address) do
      create(:clinician_address, clinician: clinician, provider_id: 1, office_key: 9452, facility_id: 1)
    end
    let!(:clinician_availabilities) do
      create(:clinician_availability, appointment_start_time: Time.zone.now + 2.hours + 1.days,
                                      appointment_end_time: Time.zone.now + 3.hours + 1.days, license_key: 9452, facility_id: 1, provider_id: 1)
    end

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })
    end

    it "responds with 401 for requests without authorization headers" do
      token_encoded_get("/api/v1/clinician_availabilities", params: {}, token: nil)

      expect(response).to have_http_status(:unauthorized)
    end

    it "responds with clinician availability" do
      token_encoded_get("/api/v1/clinician_availabilities",
                        params: { facility_id: 1, clinician_id: 1, available_date: Date.today, type_of_cares: "Child Neuro/Psych Testing" }, token: @token) # date should be in format YYYY-MM-DD

      expect(response).to have_http_status(:ok)
      expect(json_response).to include("clinician_availabilities")
    end

    it "returns clinician availability details" do
      token_encoded_get("/api/v1/clinician_availabilities",
                        params: { facility_id: 1, clinician_id: clinician.id, available_date: Time.now.utc + 2.hours, type_of_cares: "Child Neuro/Psych Testing" }, token: @token)

      expect(response).to have_http_status(:ok)
      expect(json_response).to include("clinician_availabilities")
      expect(json_response["meta"]["clinician_availability_dates"]).to eq([clinician_availabilities.available_date.to_date.to_s])
    end

    it "returns clinician availability with facility_id clinician_id available_date" do
      token_encoded_get("/api/v1/clinician_availabilities",
                        params: { facility_id: 1, clinician_id: clinician.id, available_date: (Date.today + 2.day), type_of_cares: "Child Neuro/Psych Testing" }, token: @token)

      expect(response).to have_http_status(:ok)
      expect(json_response).to include("clinician_availabilities")
      expect(json_response["clinician_availabilities"].size).to eq(0)
    end

    it "returns clinician availability with facility_id  available_date return all params are not present" do
      token_encoded_get("/api/v1/clinician_availabilities",
                        params: { facility_id: 1, clinician_id: clinician.id }, token: @token)

      expect(response).to have_http_status(:not_found)
    end
  end
end
