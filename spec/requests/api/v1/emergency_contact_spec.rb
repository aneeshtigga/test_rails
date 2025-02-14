require 'rails_helper'

RSpec.describe "EmergencyContacts", type: :request do
  describe "GET" do
    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:patient) { create(:patient) }
    let!(:emergency_contact) { create(:emergency_contact, patient: patient) }

    it "returns emergency contact for patient" do
      token_encoded_get("/api/v1/patients/emergency_contact/#{patient.id}",
                        params: {
                          patient_id: patient.id
                        }, token: @token)

      expect(json_response).to include({
                                         "first_name" => emergency_contact.first_name,
                                         "last_name" => emergency_contact.last_name,
                                         "id" => emergency_contact.id,
                                         "patient_id" => emergency_contact.patient_id,
                                         "phone" => emergency_contact.phone,
                                         "relationship_to_patient" => emergency_contact.relationship_to_patient
                                       })
    end

    describe "POST" do
      before :all do
        @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
      end

      let!(:patient) { create(:patient) }

      it "returns emergency contact id for created record" do
        token_encoded_post("/api/v1/patients/emergency_contact/",
                           params: {
                             patient_id: patient.id,
                             first_name: "Jacob",
                             last_name: "Munich",
                             phone: "+5231235432",
                             relationship_to_patient: "child"
                           }, token: @token)

        expect(json_response).to include("emergency_contact")
      end
    end
  end
end
