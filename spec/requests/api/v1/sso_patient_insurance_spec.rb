require "rails_helper"

RSpec.describe "Api::V1::SsoPatientInsurances", type: :request do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  describe "PUT update" do
    let!(:address) { create(:clinician_address) }
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let(:insurance) { create(:insurance, amd_carrier_id: 7562) }
    let!(:facility_accepted_insurance) { create(:facility_accepted_insurance, clinician_address: address, insurance: insurance) }
    let(:responsible_party) { create(:responsible_party, amd_id: 6849630) }
    let(:account_holder) { create(:account_holder, responsible_party: responsible_party) }
    let!(:patient) { create(:patient, amd_patient_id: 61722, marketing_referral_id: 433, account_holder: account_holder) } # add provider_id
    let(:intake_address) { create(:intake_address, intake_addressable: patient) }

    let(:params) do
      {
        patient_id: patient.amd_patient_id,
        is_changed: true,
        insurance_details: {
          insurance_carrier: facility_accepted_insurance.insurance.name,
          member_id: "NFC123456",
          mental_health_phone_number: "617-555-1234",
          primary_policy_holder: "other",
          provider_id: facility_accepted_insurance.clinician_address.provider_id,
          facility_id: facility_accepted_insurance.clinician_address.facility_id,
          license_key: facility_accepted_insurance.clinician_address.office_key,
          policy_holder: {
            first_name: "Captain",
            last_name: "Jaane",
            date_of_birth: "01/01/1986",
            gender: "male",
            email: "test@gmail.com"
          },
          address: {
            address_line1: "10 Storrow Dr",
            address_line2: "",
            city: "Boston",
            state: "MA",
            postal_code: "02151"
          }
        }
      }
    end

    it "responds with 401 for invalid session" do
      post("/api/v1/sso_patient_insurance")

      expect(response).to have_http_status(:unauthorized)
    end

    it "responds with 404 for invalid patient_id" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }

      post("/api/v1/sso_patient_insurance")

      expect(response).to have_http_status(404)
    end

    it "should create new record in db and AMD if there is change in existing insurance coverage" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }

      VCR.use_cassette("create_insurance_responsible_coverage_success") do
        post "/api/v1/sso_patient_insurance", params: params
      end

      expect(response).to have_http_status(200)
      expect(json_response["patient"]["insurance_coverages"].length).to eq 1
    end

    it "should not create new record if there is no change in insurance details" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }

      VCR.use_cassette("create_insurance_responsible_coverage_success") do
        post "/api/v1/sso_patient_insurance", params: params
      end
      expect(response).to have_http_status(200)
      expect(json_response["patient"]["insurance_coverages"].length).to eq 1

      VCR.use_cassette("create_insurance_responsible_coverage_success") do
        post "/api/v1/sso_patient_insurance", params: params.merge(is_changed: false)
      end

      expect(response).to have_http_status(200)
      expect(json_response["patient"]["insurance_coverages"].length).to eq 1
    end

    it "should not create new record if there is no change in insurance details" do
      skip "Bad Test Data"
      
      IntakeAddress.destroy_all

      VCR.use_cassette("create_intake_address_for_insurance_success") do
        create(:intake_address, intake_addressable: patient)
      end

      allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { selected_patient_id: "5984106", license_key: "995456" } }

      VCR.use_cassette("create_insurance_policy_coverage_success_new") do
        post "/api/v1/sso_patient_insurance", params: params
      end

      expect(response).to have_http_status(200)
      expect(json_response["patient"]["insurance_coverages"].length).to eq 1

      params[:insurance_details][:primary_policy_holder] = "self"
      
      VCR.use_cassette("create_self_insurance_policy_coverage_success_new") do
        post "/api/v1/sso_patient_insurance", params: params.merge({ is_changed: true })
      end

      expect(response).to have_http_status(200)
      expect(json_response["patient"]["insurance_coverages"].length).to eq 2
    end
  end
end
