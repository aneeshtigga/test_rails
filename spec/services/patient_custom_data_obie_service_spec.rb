require "rails_helper"

describe PatientCustomDataObieService, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let!(:clinician_address) { create(:clinician_address) }
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }
  let!(:special_case) { create(:special_case) }
  let!(:patient) do
    create(:patient, amd_patient_id: 5_983_942, marketing_referral_id: 123, special_case_id: special_case.id)
  end
  let!(:emergency_contact) { create(:emergency_contact, patient: patient)}
  let!(:patient_custom_data_service) { PatientCustomDataObieService.new(patient.id) }

  describe ".post_data" do
    it "posts patient's data to AMD custom tab named OBIE" do
      VCR.use_cassette("amd/patient_custom_data") do
        updated_record = patient_custom_data_service.post_data
        expect(updated_record["patient"]["@id"]).to eq(patient.amd_patient_id.to_s)
      end
    end
  end

  describe ".lookup_template" do
    it "gets the template fieldset from AMD" do
      VCR.use_cassette("amd/patient_custom_data") do
        field_list = patient_custom_data_service.lookup_template
        expect(field_list[0].keys).to include(:template_id)
      end
    end
  end

  describe ".patient_custom_params" do
    it "returns the payload with lookup data to post updates" do
      VCR.use_cassette("amd/patient_custom_data") do
        payload = patient_custom_data_service.patient_custom_params

        expect(payload.keys).to include(:template_id)
        expect(payload.keys).to include(:patient_id)
        expect(payload.keys).to include(:field_value_list)
      end
    end
  end

  describe ".fieldvalue_by_name" do
    it "returns preferred_name of the patient" do
      expect(patient_custom_data_service.fieldvalue_by_name("Preferred Name")).to eq(patient.preferred_name)
    end

    it "returns amd index of amd pronouns list for patients pronoun" do
      expect(patient_custom_data_service.fieldvalue_by_name("Pronouns")).to eq(1)
    end

    it "returns about value of the patient" do
      expect(patient_custom_data_service.fieldvalue_by_name("Tell us about..")).to eq(patient.about)
    end

    it "returns amd index of special_cases list for patients special_case" do
      expect(patient_custom_data_service.fieldvalue_by_name("Special Cases")).to eq(2)
    end
  end

  describe "#amd_pronoun_id" do
    it "returns amd pronoun id hash" do
      expect(patient_custom_data_service.amd_pronoun_id).to eq({
        'She/her': 1,
        'He/him': 2,
        'They/them': 3,
        Other: 4,
        'Xe/xem': 5,
        'Ze/zir': 6,
        'Not represented here': 7,
        'Prefer not to say': 8
      }.as_json)
    end
  end
end
