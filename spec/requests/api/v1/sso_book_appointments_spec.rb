require "rails_helper"

RSpec.describe "Api::V1::SsoBookAppointments", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end


  describe "POST create" do
    let!(:address) { create(:clinician_address) }
    let(:patient) { create(:patient, amd_patient_id: "5984106", marketing_referral_id: 123, office_code: 995456) }
    let(:new_patient_availability) { create(:clinician_availability, is_ia: 1, is_fu: 0) }
    let!(:existing_patient_availability) do
      create(:clinician_availability, reason: "TELE", appointment_start_time: DateTime.now.utc.change(month: 4, day: 20, hour: 19, minute: 0),
                                      appointment_end_time: DateTime.now.utc.change(month: 4, day: 20, hour: 20, minute: 0), column_id: 1153, is_ia: 0, is_fu: 1)
    end
    let!(:postal_code) { create(:postal_code, zip_code: address.postal_code, state: address.state) }
    let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") }
    let!(:amd_appointment_id) { 12_345 }
    let(:scheduler) { double("AmdAppointmentSchedulerService") }
    let!(:support_info) { create(:support_directory, license_key: address.office_key, state: address.state) }

    before do
      allow(scheduler).to receive(:schedule_appointment).and_return(amd_appointment_id)
      allow(AmdAppointmentSchedulerService).to receive(:new).and_return(scheduler)
      allow_any_instance_of(BookAppointmentService).to receive(:episode_id).and_return(5_949_591)
    end
    before do
      travel_to stub_time
    end

    after do
      travel_back
    end

    it "returns 401 for unauthorised request" do
      post "/api/v1/sso_book_appointments"

      expect(response).to have_http_status(401)
      expect(json_response["message"]).to eq("Session expired")
    end

    it "returns 404 for request with invalid patient_id" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }
      post "/api/v1/sso_book_appointments", params: { patient_id: 123 }

      expect(response).to have_http_status(:not_found)
      expect(json_response["message"]).to eq("Patient not found")
    end

    it "returns 404 for request without clinician_availability_key" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }
      VCR.use_cassette("create_patient_intake_address_data") do
        post "/api/v1/sso_book_appointments", params: { patient_id: patient.amd_patient_id }

        expect(response).to have_http_status(:not_found)
        expect(json_response["message"]).to eq("Appointment no longer available")
      end
    end

    it "returns 404 for request with clinician_availability_key of new patient availability" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }
      VCR.use_cassette("create_patient_intake_address_data") do
        post "/api/v1/sso_book_appointments",
             params: { patient_id: patient.amd_patient_id, clinician_availability_key: new_patient_availability.clinician_availability_key }

        expect(response).to have_http_status(:not_found)
        expect(json_response["message"]).to eq("Appointment no longer available")
      end
    end

    it "returns 200 for valid request and availability" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }
      address.clinician.update(provider_id: existing_patient_availability.provider_id, license_key: existing_patient_availability.license_key)
      VCR.use_cassette("create_existing_patient_appointment") do
        post "/api/v1/sso_book_appointments",
             params: { patient_id: patient.amd_patient_id, clinician_availability_key: existing_patient_availability.clinician_availability_key }
      end
      expect(response).to have_http_status(:ok)
    end
  end
end
