require "rails_helper"

RSpec.describe Amd::Data::PatientInsurances, type: :class do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:address) { create(:clinician_address) }
  let(:patient) { create(:patient, amd_patient_id: "5984602", marketing_referral_id: 123, office_code: 995456) }
  let!(:hippa_relationship) { create(:hipaa_relationship_code, code: 18, description: "Self") }
  let(:data) do
    { "patientlist" => {
      "patient" => {
        "@id" => "pat5984602",
        "@name" => "VINOB,KRUPA",
        "insplanlist" => {
          "insplan" => {
            "@id" => "ins3701131",
            "@carrier" => "car62869",
            "@subscriber" => "resp6850383",
            "@subscribernum" => "678678",
            "@relationship" => "1",
            "@hipaarelationship" => "18"
          }
        }
      }
    },
      "resppartylist" => {
        "respparty" => {
          "@id" => "resp6850383", "@name" => "VINOB,KRUPA", "@dob" => "01/03/1992", "@sex" => "F"
        }
      },
      "carrierlist" => {
        "carrier" => { "@id" => "car62869", "@name" => "XANTHEM BCBS" }
      } }
  end

  let!(:patient_insurance) { Amd::Data::PatientInsurances.new(data) }

  describe "returns response of patients insurance" do 
    it "returns the patient_id" do
      expect(patient_insurance.patient_id).to eq(data["patientlist"]["patient"]["@id"].gsub("pat", "").to_i)
    end

    it "returns the patient_name as per AMD format" do
      expect(patient_insurance.patient_full_name).to eq(data["patientlist"]["patient"]["@name"])
    end

    it "returns response" do
      expect(patient_insurance.response.keys).to include(:insurance_details)
    end

    it "returns response with required insurance details" do
      expect(patient_insurance.response[:insurance_details][0].keys).to include(:insurance_carrier)
      expect(patient_insurance.response[:insurance_details][0].keys).to include(:member_id)
      expect(patient_insurance.response[:insurance_details][0].keys).to include(:primary_policy_holder)
      expect(patient_insurance.response[:insurance_details][0].keys).to include(:insurance_carrier)
      expect(patient_insurance.response[:insurance_details][0].keys).to include(:policy_holder)
    end

    it "returns the amd_insurance_id" do
      patient_insurance.insurances
      expect(patient_insurance.amd_insurance_id).to eq(data["patientlist"]["patient"]["insplanlist"]["insplan"]["@id"])
    end
  end
end
