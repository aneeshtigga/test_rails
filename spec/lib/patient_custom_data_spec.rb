require "rails_helper"

describe PatientCustomData, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }
  let!(:special_case) { create(:special_case) }
  let!(:patient) do
    create(:patient, amd_patient_id: 5_983_942, marketing_referral_id: 123, special_case_id: special_case.id)
  end
  let!(:emergency_contact) { create(:emergency_contact, patient: patient)}
  let!(:patient_custom_data) { PatientCustomData.new(patient.id) }
  before(:each) do
    allow_any_instance_of(PatientCustomData).to receive(:field_value_list).and_return({
      '@templatefieldid': "123",
      '@value': "data"
    })
    allow_any_instance_of(PatientCustomData).to receive(:tab_code).and_return("OBIE")
  end

  describe ".post_data" do
    it "posts patients custom data to AMD" do
      VCR.use_cassette("amd/patient_custom_data") do
        updated_record = patient_custom_data.post_data
        expect(updated_record["patient"]["@id"]).to eq(patient.amd_patient_id.to_s)
      end
    end
  end

  describe ".post_data" do
    let!(:patient) do
      create(:patient, amd_patient_id: 5_983_942, marketing_referral_id: 123, special_case_id: special_case.id, amd_pronouns_updated: true)
    end

    let!(:patient_custom_data) { PatientCustomData.new(patient.id) }

    it "will not make call to AMD, if posts patients custom data is sent to AMD previously" do
      expect(patient_custom_data.post_pronouns_data).to be(nil)
    end
  end

  describe ".lookup_template" do
    it "gets the template fieldset from AMD" do
      VCR.use_cassette("amd/patient_custom_data") do
        field_list = patient_custom_data.lookup_template
        expect(field_list[0].keys).to include(:template_id)
      end
    end
  end

  describe ".patient_custom_params" do
    it "returns the payload with lookup data to post updates" do
      VCR.use_cassette("amd/patient_custom_data") do
        payload = patient_custom_data.patient_custom_params

        expect(payload.keys).to include(:template_id)
        expect(payload.keys).to include(:patient_id)
        expect(payload.keys).to include(:field_value_list)
      end
    end
  end

  describe ".fieldvalue_by_name" do
    it "raises NotImplementedError" do
      expect { patient_custom_data.fieldvalue_by_name("Preferred Name") }.to raise_error(NotImplementedError)
    end
  end

  describe ".tab_code" do
    it "raises NotImplementedError" do
      expect { patient_custom_data.fieldvalue_by_name("Preferred Name") }.to raise_error(NotImplementedError)
    end
  end
end