require "rails_helper"

describe PatientCustomDataPtContactService, type: :class do
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
  let!(:patient_custom_data_service) { PatientCustomDataPtContactService.new(patient.id) }
  let!(:emergency_contact) { create(:emergency_contact, patient: patient) }

  describe ".post_data" do
    context "when there is an emergency_contact" do
      it "posts emergency contact data to AMD custom tab named Pt Contact" do
        VCR.use_cassette("amd/patient_custom_data_pt_contact") do
          updated_record = patient_custom_data_service.post_data
          expect(updated_record["patient"]["@id"]).to eq(patient.amd_patient_id.to_s)
        end
      end
    end

    context "when there is no emergency_contact" do
      it "does not try to send data to AMD" do
        VCR.use_cassette("amd/patient_custom_data_pt_contact") do
          patient2 = create(:patient, amd_patient_id: 5_984_602, marketing_referral_id: 123)
          custom_data_service = PatientCustomDataPtContactService.new(patient2.id)
          allow(custom_data_service).to receive(:patient_custom_params)
          custom_data_service.post_data
          expect(custom_data_service).not_to have_received(:patient_custom_params)
        end
      end
    end
  end

  describe ".fieldvalue_by_name" do
    it "returns full name of the emergency_contact" do
      expect(patient_custom_data_service.fieldvalue_by_name("Contact")).to eq(emergency_contact.full_name)
    end

    it "returns relationship value of the emergency_contact" do
      expect(patient_custom_data_service.fieldvalue_by_name("Relationship")).to eq(emergency_contact.relationship_to_patient_text)
    end

    it "returns phone value of the emergency_contact" do
      expect(patient_custom_data_service.fieldvalue_by_name("Phone")).to eq(emergency_contact.phone)
    end
  end

  describe ".tab_code" do
    it "returns the correct amd custom data tab code" do
      expect(patient_custom_data_service.tab_code).to eq("#PC")
    end
  end
end
