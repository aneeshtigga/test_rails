require "rails_helper"

RSpec.describe "Patient Insurance Coverages", type: :request do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:skip_intake_address_amd) { skip_intake_address_amd_creation }
  let!(:insurance) {create(:insurance)}
  let!(:clinician)  {create(:clinician)}
  let!(:address)  {create(:clinician_address,clinician: clinician)}
  let!(:facility_accepted_insurance) {create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)}

  before :all do
    @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
  end 

  describe "POST /api/v1/patients/:id/insurances_coverages" do
    let!(:address) { create(:clinician_address) }
    let(:insurance) { create(:insurance, amd_carrier_id: 7562)}
    let!(:facility_accepted_insurance) { create(:facility_accepted_insurance, clinician_address: address, insurance: insurance) }
    let(:responsible_party) { create(:responsible_party, amd_id: 6849630)}
    let(:account_holder) { create(:account_holder, responsible_party: responsible_party) }
    let(:patient) { create(:patient, amd_patient_id: 61722, marketing_referral_id:433, account_holder: account_holder) } #add provider_id
    let!(:intake_address) { create(:intake_address, intake_addressable: patient)}
    let(:params) do
      {
        'insurance_details': {
          'insurance_carrier': facility_accepted_insurance.insurance.name,
          'member_id': "NFC123456",
          'mental_health_phone_number': "617-555-1234",
          'primary_policy_holder': "other",
          'provider_id': facility_accepted_insurance.clinician_address.provider_id,
          'facility_id': facility_accepted_insurance.clinician_address.facility_id,
          'license_key': facility_accepted_insurance.clinician_address.office_key,
          'policy_holder': {
            'first_name': "Captain",
            'last_name': "Jaane",
            'date_of_birth': "01/01/1986",
            'gender': "male",
            'email': "test@gmail.com"
          },
          'address': {
              'address_line1': "10 Storrow Dr",
              'address_line2': "",
              'city': "Boston",
              'state': "MA",
              'postal_code': "02151"
          }
        }
      }
    end

    context "when patient not found" do
      it "returns status code 404" do
        invalid_patient_id = 100
        token_encoded_put("/api/v1/patients/#{invalid_patient_id}/insurance_coverages", params: params, token: @token)

        expect(response).to have_http_status(404)
        expect(json_response["message"]).to include("Patient not found")
      end
    end

    context "for valid request" do 
      it "return 200 on success" do
        VCR.use_cassette("create_insurance_responsible_coverage_success") do
          token_encoded_put("/api/v1/patients/#{patient.id}/insurance_coverages", params: params, token: @token)

          expect(response).to have_http_status(200)
        end 
      end
    end

    context "for invalid request" do
      it "returns 401 for an unauthorized request" do
        params = {
          'insurance_details': {
            'insurance_carrier': "Aetna",
            'member_id': "NFC123456",
            'mental_health_phone_number': "617-555-1234",
            'primary_policy_holder': "spouse",
          }
        }

        token_encoded_put("/api/v1/patients/#{patient.id}/insurance_coverages", params: params, token: nil)

        expect(response).to have_http_status(401)
      end

      it "respond with error for request without required params" do
        params = {
          'insurance_details': {
            'member_id': "NFC123456",
            'mental_health_phone_number': "617-555-1234",
            'primary_policy_holder': "spouse",
          }
        }
        VCR.use_cassette("create_responsible_party_success") do
          token_encoded_put("/api/v1/patients/#{patient.id}/insurance_coverages", params: params, token: @token)
          expect(json_response["message"]).to eq("Error occured in saving insurance information")
          expect(json_response["error"]).to eq("Validation failed: Company name can't be blank")
       end
      end
    end
  end
end
