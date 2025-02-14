require "rails_helper"

RSpec.describe "Api::V1::SsoClinicianAvailabilities", type: :request do
  describe "GET /index" do
    let!(:clinician) { create(:clinician) }
    let!(:address) do
      create(:clinician_address, clinician_id: clinician.id, provider_id: clinician.provider_id,
                                 office_key: clinician.license_key)
    end
    let!(:availability) do
      create(:clinician_availability, appointment_start_time: Time.zone.now + 1.week, reason: "TELE",
                                      provider_id: address.provider_id, facility_id: address.facility_id, license_key: address.office_key, virtual_or_video_visit: 1, in_person_visit: 0)
    end

    it "returns 401 for unauthorized request" do
      get "/api/v1/sso_clinician_availabilities", params: {}

      expect(response).to have_http_status 401
    end

    it "returns 404 for invalid clinician Id" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) {
                                                          { selected_patient_id: "5984106", license_key: "995456" }
                                                        }
      get "/api/v1/sso_clinician_availabilities", params: { clinician_id: nil }

      expect(response).to have_http_status 404
    end

    it "returns 200 for request with valid session and clinician id" do
      address = create(:clinician_address)
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) {
                                                          { selected_patient_id: "5984106", license_key: "995456" }
                                                        }
      get "/api/v1/sso_clinician_availabilities", params: { clinician_id: address.clinician_id }

      expect(response).to have_http_status 200
    end

    it "returns video visit availabilities when requested for video visits" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) {
                                                          { selected_patient_id: "5984106", license_key: "995456" }
                                                        }
      get "/api/v1/sso_clinician_availabilities", params: { clinician_id: address.clinician_id }

      expect(json_response["clinician_availabilities"]).not_to be_empty
      expect(response).to have_http_status 200
    end

    it "returns only existing patient availabilities if available" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) {
                                                          { selected_patient_id: "5984106", license_key: "995456" }
                                                        }
      get "/api/v1/sso_clinician_availabilities", params: { clinician_id: address.clinician_id }

      expect(json_response["clinician_availabilities"].map { |x| x["reason"] }).not_to include(APPOINTMENT_TYPES)
      expect(response).to have_http_status 200
    end

    it "returns virtual availabilities when requested for video visits" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) {
                                                          { selected_patient_id: "5984106", license_key: "995456" }
                                                        }
      get "/api/v1/sso_clinician_availabilities",
          params: { clinician_id: address.clinician_id, modality: "video_visits" }

      expect(json_response["clinician_availabilities"].map { |x| x["virtual_or_video_visit"] }.uniq).to eq([1])
      expect(json_response["clinician_availabilities"].map { |x| x["in_person_visit"] }.uniq).to eq([0])
      expect(response).to have_http_status 200
    end

    it "returns virtual availabilities when requested for in_office visits" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) {
                                                          { selected_patient_id: "5984106", license_key: "995456" }
                                                        }
      availability.update(in_person_visit:1)
      get "/api/v1/sso_clinician_availabilities",
          params: { clinician_id: address.clinician_id, modality: "in_office_visits" }

      expect(json_response["clinician_availabilities"].map { |x| x["in_person_visit"] }.uniq).to eq([1])
      expect(response).to have_http_status 200
    end

    it "returns in-office availabilities only for requested facilities" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) {
                                                          { selected_patient_id: "5984106", license_key: "995456" }
                                                        }
      get "/api/v1/sso_clinician_availabilities",
          params: { clinician_id: address.clinician_id, facility_id: address.facility_id }

      expect(json_response["clinician_availabilities"][0]["facility_id"]).to eq(address.facility_id)
      expect(response).to have_http_status 200
    end
  end
end
