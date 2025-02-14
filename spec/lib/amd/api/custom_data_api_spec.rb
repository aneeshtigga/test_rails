require "rails_helper"
require "#{Rails.root}/spec/support/mocks_and_stubs/amd_api_baseapi_stub"

RSpec.describe Amd::Api::CustomDataApi, type: :class do
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
    end
  end

  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }
  let!(:clinician_address) { create(:clinician_address) }
  let!(:special_case) { create(:special_case) }
  let!(:patient) do
    create(:patient, amd_patient_id: 5_983_942, marketing_referral_id: 123, special_case_id: special_case.id)
  end
  let!(:emergency_contact) {create(:emergency_contact, patient: patient)}
  let(:custom_data_api) { Amd::Api::CustomDataApi.new(config, authenticate_amd(102).base_url, authenticate_amd(102).token) }
  let!(:patient_custom_data_service) { PatientCustomDataObieService.new(patient.id) }

  describe "#save_patients_data" do
    it "updates the custom template with patients data" do
      field_value = [
        { "@templatefieldid"=>"5159", "@value"=>"Dav" },
        {"@templatefieldid"=>"5164", "@value"=>1},
        {"@templatefieldid"=>"5160", "@value"=>"Been through couple of theraphies in the past"},
        {"@templatefieldid"=>"5163", "@value"=>2}
      ]

      allow(Amd::AmdClient).to receive(:new).and_return(OpenStruct.new(custom_data: custom_data_api))
      allow_any_instance_of(PatientCustomDataObieService).to receive(:fieldvalue_by_name).and_return(field_value)
      allow_any_instance_of(Amd::Api::CustomDataApi).to receive(:lookup_custom_template).and_return([{ template_id: 515 }])

      patient_custom_params = patient_custom_data_service.patient_custom_params
      custom_data_api.load_fake_response_from("amd/patient_custom_data_3")
      updated_patient = custom_data_api.save_patients_data(patient_custom_params)

      expect(updated_patient["patient"]["@id"]).to eq(patient_custom_params[:patient_id].to_s)
    end
  end

  describe "#lookup_custom_template" do
    it "returns the fields set of custom tab with template_id" do
      custom_data_api.load_fake_response_from("amd/patient_custom_data_2")
      field_set = custom_data_api.lookup_custom_template("OBIE")

      expect(field_set).to_not be_empty
      expect(field_set[0].keys).to include(:template_id)
    end
  end
end
