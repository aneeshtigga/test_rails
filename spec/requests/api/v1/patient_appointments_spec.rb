require "rails_helper"

RSpec.describe "Api::V1::PatientAddresses", type: :request do
  let!(:skip_patient_amd) { skip_patient_amd_creation }

  before :all do
    @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
  end

  describe "PUT /api/v1/patients/:id" do
    context "when patient appointment is not found" do
      before { token_encoded_get("/api/v1/patient_appointments/0", params: {}, token: @token) }

      it "returns status code 404" do
        expect(response).to have_http_status(404)
        expect(json_response["message"]).to include("Patient Appointment not found")
      end
  end

    context "when patient appointment is found" do
      let(:clinician) { create(:clinician) }
      let(:clinician_address) { create(:clinician_address) }
      let!(:marketing_referral) { create(:marketing_referral, amd_marketing_referral: "PPP", phone_number: "(312) 761-8365") }
      let(:account_holder) { create(:account_holder) }
      let(:patient) { create(:patient, referral_source: "PPP", account_holder: account_holder) }
      let(:patient_appointment) do
        create(:patient_appointment, clinician: clinician, clinician_address: clinician_address, patient: patient)
      end
      let!(:support_directory) do 
        create(:support_directory,
                                        license_key: patient_appointment.clinician_address.office_key,
                                        state: clinician_address.state)
      end

      before { token_encoded_get("/api/v1/patient_appointments/#{patient_appointment.id}", params: {}, token: @token) }

      it "returns status code 200" do
        expect(response).to have_http_status(200)

        expect(json_response["patient_appointment"]).to include({
                                                                  "id" => patient_appointment.id,
                                                                  "duration" => patient_appointment.duration,
                                                                  "modality" => patient_appointment.appointment.modality,
                                                                  "appointment_start_time" => "2021-07-27T16:00:00.000Z",
                                                                  "appointment_end_time" => "2021-07-27T16:30:00.000Z",
                                                                  "type_of_care" => patient_appointment.type_of_care,
                                                                  "appointment_occurred_in_past" => true,
                                                                  "marketing_referral_phone" => nil
                                                                })

        expect(json_response["patient_appointment"]["clinician"]).to include({
                                                                               "id" => clinician.id,
                                                                               "first_name" => clinician.first_name,
                                                                               "last_name" => clinician.last_name,
                                                                               "license_type" => clinician.license_type,
                                                                               "telehealth_url" => clinician.telehealth_url,
                                                                               "profile_photo" => clinician.presigned_photo
                                                                             })

        expect(json_response["patient_appointment"]["clinician_address"]).to include({
                                                                                       "id" => clinician_address.id,
                                                                                       "address_line1" => clinician_address.address_line1,
                                                                                       "address_line2" => clinician_address.address_line2,
                                                                                       "city" => clinician_address.city,
                                                                                       "state" => clinician_address.state,
                                                                                       "postal_code" => clinician_address.postal_code,
                                                                                       "facility_name" => clinician_address.facility_name,
                                                                                       "license_key" => clinician_address.office_key
                                                                                     })
        expect(json_response["patient_appointment"]["support_info"]).to include({
                                                                                  "support_number" => support_directory.intake_call_in_number,
                                                                                  "location" => support_directory.location,
                                                                                  "support_hours" => support_directory.support_hours,
                                                                                  "established_patients_call_in_number" => support_directory.established_patients_call_in_number,
                                                                                  "follow_up_url" => support_directory.follow_up_url
                                                                                })
      end
    end
  end
end
