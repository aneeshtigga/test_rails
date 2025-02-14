require "rails_helper"

require "#{Rails.root}/spec/support/mocks_and_stubs/amd_api_baseapi_stub"


RSpec.describe Amd::Api::ReferralApi, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let(:config) do
    Amd::AmdConfiguration.setup do |config|
      config.request_endpoint = "xmlrpc/processrequest.aspx"
      config.referral_endpoint = "referral/MarketingReferrals"
      config.referral_request_url = "https://provapi.advancedmd.com/api/api-102"
    end
  end
  let!(:clinician_address) { create(:clinician_address) }
  let(:referral_api) { Amd::Api::ReferralApi.new(config, authenticate_amd(102).base_url, authenticate_amd(102).token) }


  describe ".add_patients_referral_source" do
    it "posts AMD to associate marketing source to patient" do
      skip_patient_amd_creation
      # patient_api = instance_double('Amd::Api::PatientApi', lookup_patient: '')
      # allow(Amd::AmdClient).to receive(:new).and_return(OpenStruct.new(patients: patient_api))
      patient = create(:patient, first_name: "test", amd_patient_id: 5983942)
      referral_api.load_fake_response_from('amd/add_patient_referral')

      expected_response = OpenStruct.new(body: '{ "id": 123 }')

      expect(referral_api).to receive(:lookup_ref_status).with("1-SCHEDULED CONSULT").once
      expect(referral_api).to receive(:send_referral_request)
        .with(anything, "referral_request", "api")
        .once
        .and_return(expected_response)

      expect(referral_api.add_patients_referral_source(patient.amd_patient_id, 19)).to eq 123
    end
  end

  describe ".lookup_ref_source" do

    it "posts AMD to associate marketing source to patient" do
      skip_patient_amd_creation
      patient = create(:patient, first_name: "test", amd_patient_id: 5983942)

      referral_api.load_fake_response_from('amd/get_referral_status_id')
      expect(referral_api.lookup_ref_status('1-SCHEDULED CONSULT')).to_not be nil
    end
  end
end
