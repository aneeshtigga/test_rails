require "rails_helper"
RSpec.describe "Api::V1::ResendBookingAppointmentEmail", type: :request do
  describe "PUT /api/v1/resend_booking_appointment_email" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:clinician) { create(:clinician) }
    let!(:address) { create(:clinician_address, clinician: clinician) }
    let!(:patient) do
      VCR.use_cassette("amd/push_referral") do
         create(:patient, amd_patient_id: 5_983_942)
       end
    end
    let!(:toc) { create(:type_of_care, clinician: clinician) }

    let!(:appointment) { create(:appointment, clinician: clinician, clinician_address: address) }
    let!(:patient_appointment) { create(:patient_appointment, patient: patient, appointment: appointment, clinician: clinician, clinician_address: address) }
    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end

    it "updates patient holder email with status 200" do
      token_encoded_patch("/api/v1/resend_booking_appointment_email/#{patient_appointment.id}", params: {'email': "test@gmail.com"}, token: @token)

      expect(PatientAppointmentHoldMailerWorker.jobs.size).to eq(1)
      expect(response).to have_http_status(:ok)
      expect(Patient.all.size).to eq(1)
      expect(Patient.first).to have_attributes('email': "test@gmail.com")
    end

    it "throws status not found when wrong patient_appointment_id passed" do
      token_encoded_patch("/api/v1/resend_booking_appointment_email/nil", params: {'email': nil}, token: @token)

      expect(response).to have_http_status(:not_found)
      expect(json_response["message"]).to eq("Patient Appointment not found")
    end

    it "throws error when email not provided in  resend_booking_appointment_email passed" do
      token_encoded_patch("/api/v1/resend_booking_appointment_email/#{patient_appointment.id}", params: {'email': nil}, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
