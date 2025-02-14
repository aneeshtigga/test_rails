require "rails_helper"

RSpec.describe "Api::V1::AppointmentCancellations", type: :request do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end


  let!(:skip_patient_amd) { skip_patient_amd_creation }

  describe "PUT /api/v1/appointment_cancellations/:id" do
    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end
    let!(:clinician) { create(:clinician) }
    let!(:address) { create(:clinician_address, clinician: clinician) }
    let!(:patient) do
      Sidekiq::Testing.inline! do
        VCR.use_cassette("amd/push_referral") do
          create(:patient, amd_patient_id: 5_983_942)
        end
      end
    end
    let!(:toc) { create(:type_of_care, clinician: clinician) }

    let!(:appointment) do
      create(:appointment, clinician: clinician, clinician_address: address, start_time: 10.days.from_now,
                           end_time: 10.days.from_now + 1.hour)
    end
    let!(:patient_appointment) do
      create(:patient_appointment, patient: patient, appointment: appointment, clinician: clinician,
                                   clinician_address: address)
    end

    let!(:appointment_1) do
      create(:appointment, clinician: clinician, clinician_address: address, start_time: 1.day.from_now,
                           end_time: 1.day.from_now + 1.hour)
    end
    let!(:patient_appointment_1) do
      create(:patient_appointment, patient: patient, appointment: appointment_1, clinician: clinician,
                                   clinician_address: address)
    end

    let!(:appointment_2) do
      create(:appointment, clinician: clinician, clinician_address: address, start_time: 1.day.from_now + 20.hours,
                           end_time: 1.day.from_now + 21.hours)
    end

    let!(:appointment_3) do
      create(:appointment, clinician: clinician, clinician_address: address, start_time: 1.day.ago + 20.hours,
                           end_time: 1.day.ago + 21.hours)
    end

    let!(:patient_appointment_2) do
      create(:patient_appointment, patient: patient, appointment: appointment_2, clinician: clinician,
                                   clinician_address: address)
    end

    let!(:patient_appointment_3) do
      create(:patient_appointment, patient: patient, appointment: appointment_2, clinician: clinician,
                                   clinician_address: address, status: "cancelled")
    end

    let!(:patient_appointment_4) do
      create(:patient_appointment, patient: patient, appointment: appointment_3, clinician: clinician,
                                   clinician_address: address, status: "cancelled")
    end

    it "returns 401 for request without Authorization headers" do
      token_encoded_put("/api/v1/appointment_cancellations/#{patient_appointment.id}", params: nil, token: nil)

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 for invalid patient appointment id" do
      token_encoded_put("/api/v1/appointment_cancellations/0", params: nil, token: @token)
      expect(response).to have_http_status(:not_found)
      expect(json_response["message"]).to eq("Patient Appointment not found")
    end

    it "returns 200 on successful cancellation of appointment" do
      skip "VCR is awful and uneeded"
      VCR.use_cassette("amd/cancel_appointment_new") do
        VCR.use_cassette("amd/cancel_appointment_success_new") do
          token_encoded_put("/api/v1/appointment_cancellations/#{patient_appointment.id}", params: nil, token: @token)
          patient_appointment.reload

          expect(response).to have_http_status(:ok)
          expect(patient_appointment.status).to eq("cancelled")
        end
      end
    end

    it "returns error on cancellation of appointment" do
      VCR.use_cassette("amd/cancel_appointment_failed") do
        token_encoded_put("/api/v1/appointment_cancellations/#{patient_appointment.id}", params: nil, token: @token)
        patient_appointment.reload

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns cancellation not allowed before 48 hours from appointment time" do
      token_encoded_put("/api/v1/appointment_cancellations/#{patient_appointment_1.id}", params: nil, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["message"]).to eq("Cancellations are only accepted more than 48 business hours before the appointment.")
      expect(json_response["cancellation_48_hours_flag"]).to be_falsy
    end

    it "returns cancellation not allowed before 48 hours from appointment time" do
      token_encoded_put("/api/v1/appointment_cancellations/#{patient_appointment_2.id}", params: nil, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["message"]).to eq("Cancellations are only accepted more than 48 business hours before the appointment.")
      expect(json_response["cancellation_48_hours_flag"]).to be_falsy
    end

    it "returns appointment already cancelled" do
      token_encoded_put("/api/v1/appointment_cancellations/#{patient_appointment_3.id}", params: nil, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["message"]).to eq("Appointment already cancelled")
      expect(json_response["already_cancelled_flag"]).to be true
    end

    it "returns appointment already occured in past" do
      token_encoded_put("/api/v1/appointment_cancellations/#{patient_appointment_4.id}", params: nil, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["message"]).to eq("Appointment already occured in past")
      expect(json_response["appointment_occured_past_flag"]).to be true
    end
  end
end
