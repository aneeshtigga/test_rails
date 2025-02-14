require 'rails_helper'

RSpec.describe "Api::V1::SsoClinicians", type: :request do
  describe "GET /api/v1/sso_clinician/:id/modalities" do

    it "returns 401 for unauthorised request" do 
      get "/api/v1/sso_clinician/1/modalities"

      expect(response).to have_http_status(401)
    end

    it "returns 404 for request with invalid clinician_id" do 
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { {selected_patient_id: "5984106", license_key: "995456"} }
      get "/api/v1/sso_clinician/1/modalities"

      expect(response).to have_http_status(:not_found)
    end

    it "returns modalities available for valid clinician id" do 
      address = create(:clinician_address, :with_clinician_availability)
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { {selected_patient_id: "5984106", license_key: "995456"} }
      ClinicianAvailability.last.update(reason: "TeleCare", appointment_start_time: Time.now+1.week, provider_id: 571)
      Clinician.last.update(provider_id: 571,license_key: 995456)
      ClinicianAvailability.last.reload
      get("/api/v1/sso_clinician/#{address.clinician_id}/modalities")

      expect(response).to have_http_status(:success)
      expect(json_response["modalities"]).to eq(["video_visits", "in_office_only"])
    end
  end

  describe "GET /api/v1/sso_clinician/:id/locations" do

    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let(:patient) do 
      create(:patient, amd_patient_id: 5983942, marketing_referral_id: 123)
    end

    let(:session_params) do
      {:id=>5983942, :name=>"GODINEZ ROGELIO", :date_of_birth=>"12/04/1989", :location => "TEST STREET,MONTGOMERY,AL,36111" , :gender=>"male"}
    end

    let!(:postal_code) { create(:postal_code, zip_code: "36111")}

    it "returns 401 for unauthorised request" do 
      get "/api/v1/sso_clinician/1/locations"

      expect(response).to have_http_status(401)
    end

    it "returns 404 for request with invalid clinician_id" do 
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { {selected_patient_id: "5984106", license_key: "995456"} }
      get "/api/v1/sso_clinician/1/locations"

      expect(response).to have_http_status(:not_found)
    end

    it "returns locations available for valid clinician id" do 
      address = create(:clinician_address, :with_clinician_availability)
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { {selected_patient_id: "5984106", license_key: "995456", authorized_patients_list: [session_params]} }
      ClinicianAvailability.last.update(reason: "TeleCare", appointment_start_time: Time.now+1.week, provider_id: 571)
      Clinician.last.update(provider_id: 571,license_key: 995456)
      address.update(provider_id: 571) 
      VCR.use_cassette("location_to_coordinates_service") do
        get "/api/v1/sso_clinician/#{address.clinician_id}/locations", params:{patient_id: patient.amd_patient_id}
      end
      expect(response).to have_http_status(:success)
      expect(json_response["locations"][0]["id"]).to eq(address.id)
    end

    it "returns clinician locations with distance under response" do 
      address = create(:clinician_address, :with_clinician_availability)
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { {selected_patient_id: "5984106", license_key: "995456", authorized_patients_list: [session_params] } }
      ClinicianAvailability.last.update(reason: "TeleCare", appointment_start_time: Time.now+1.week, provider_id: 571)
      Clinician.last.update(provider_id: 571,license_key: 995456)
      address.update( provider_id: 571)
      address.dup.update(address_line1: "25111 Country Club Blvd St 290",city: "Montgomery", postal_code: "36112", latitude: 37.792, longitude: -122.393)
      VCR.use_cassette("location_to_coordinates_service") do
        get "/api/v1/sso_clinician/#{address.clinician_id}/locations", params:{patient_id: patient.amd_patient_id}
      end
      expect(response).to have_http_status(:success)
      expect(json_response["locations"].length).to eq(2)
      expect(json_response["locations"][0]["distance_in_miles"]).to be <= (json_response["locations"][1]["distance_in_miles"])
    end 
  end
end
