require "rails_helper"

RSpec.describe "Api::V1::Cancellations", type: :request do
  describe "POST /api/v1/cancellations" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
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
      create(:appointment, clinician: clinician, clinician_address: address, start_time: Time.zone.now + 10.days,
                           end_time: Time.zone.now + 10.days + 1.hour)
    end
    let!(:patient_appointment) do
      create(:patient_appointment, patient: patient, appointment: appointment, clinician: clinician,
                                   clinician_address: address)
    end
    let!(:clinician_availability_status) do
      create(:clinician_availability_status, clinician_availability_key: appointment.clinician_availability_key, available_date: appointment.start_time)
    end
    let!(:cancellation_reason) { create(:cancellation_reason) }
      
      context "when it success" do
        it "creates a new cancellation 200 created" do
          token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
          token_encoded_post("/api/v1/cancellations",
                              params: { cancellation_reason_id: cancellation_reason.id, 
                                patient_appointment_id: patient_appointment.id, 
                                cancelled_by: "Patient"},
                                token: token)

          expect(response).to have_http_status(:ok)
          cancellation = Cancellation.last

          expect(Cancellation.all.size).to eq(1)
          expect(cancellation).to have_attributes(cancellation_reason_id: cancellation_reason.id, patient_appointment_id: patient_appointment.id, cancelled_by: "Patient")

          expect(json_response).to include(
            "cancellation_id" => cancellation.id
          )

          expect(ClinicianAvailabilityStatus.find_by(clinician_availability_key: appointment.clinician_availability_key)).to be nil
        end
      end
  end
end