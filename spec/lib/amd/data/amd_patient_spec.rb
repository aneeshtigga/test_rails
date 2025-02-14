require "rails_helper"

RSpec.describe Amd::Data::AmdPatient, type: :class do
  let!(:clinician) { create(:clinician, provider_id: 123) }
  let!(:clinician_address) do
    create(:clinician_address, clinician: clinician, provider_id: clinician.provider_id, office_key: 995_456)
  end
  let!(:clinician_availability) do
    create(:clinician_availability, provider_id: clinician.provider_id, profile_id: 3, column_id: 1,
                                    facility_id: clinician_address.facility_id)
  end
  let(:responsible_party) { create(:responsible_party, amd_id: "123456") }
  let(:account_holder) { create(:account_holder, responsible_party: responsible_party) }
  let(:patient) do
    create(:patient, amd_patient_id: 5_983_942, office_code: 995_456, provider_id: 123,
                     search_filter_values: { zip_codes: clinician_address.postal_code, clinician_address_id: clinician_address.id }, account_holder: account_holder, marketing_referral_id: "123")
  end
  let(:intake_address) { create(:intake_address, intake_addressable: patient) }
  let!(:skip_patient_amd) { skip_patient_amd_creation }

  describe "AmdPatient object methods" do
    HipaaRelationshipCode.create(code: 19, description: "Child")

    let(:amd_patient) do
      VCR.use_cassette("amd/push_referral") do
        Amd::Data::AmdPatient.new(patient)
      end
    end

    it "#name" do
      expect(amd_patient.name).to eq("#{patient.last_name}, #{patient.first_name}")
    end

    it "#sex" do
      expect(amd_patient.sex).to eq(patient.gender)
    end

    it "#dob" do
      expect(amd_patient.dob).to eq(patient.date_of_birth.to_date.strftime("%m/%d/%Y"))
    end

    it "#relationship" do
      expect(amd_patient.relationship).to eq(3) # 3 equals to child
    end

    it "#hipaarelationship" do
      skip "Bad Test Data"
      expect(amd_patient.hipaarelationship).to eq(19) # HIPPA relationship
    end

    it "#chart" do
      expect(amd_patient.chart).to eq("AUTO")
    end

    it "#zip" do
      expect(amd_patient.zip).to eq(patient.intake_address&.postal_code)
    end

    it "#city" do
      expect(amd_patient.city).to eq(patient.intake_address&.city)
    end

    it "#state" do
      expect(amd_patient.state).to eq(patient.intake_address&.state)
    end

    it "#address1" do
      expect(amd_patient.address1).to eq(patient.intake_address&.address1)
    end

    it "#address2" do
      expect(amd_patient.address2).to eq(patient.intake_address&.address2)
    end

    it "#otherphone" do
      expect(amd_patient.otherphone).to eq(patient.phone_number)
    end

    it "#othertype" do
      expect(amd_patient.othertype).to eq("C")
    end

    it "#respparty_name" do
      expect(amd_patient.respparty_name).to eq("resp123456")
    end

    it "#respparty" do
      expect(amd_patient.respparty).to eq("resp123456")
    end

    it "#id" do
      expect(amd_patient.id).to eq(patient.amd_patient_id)
    end

    it "#profile" do
      expect(amd_patient.profile).to eq(3)
    end

    it "returns email if patient is not child" do
      skip_patient_amd_creation
      patient.update(account_holder_relationship: "self")
      expect(amd_patient.email).to eq(patient.account_holder.email)
    end

    context "email params" do
      let(:responsible_party) { create(:responsible_party, amd_id: "123456") }
      let(:account_holder) { create(:account_holder, responsible_party: responsible_party) }
      let(:child_patient) do
        create(:patient, account_holder_relationship: "child", amd_patient_id: 5_983_942, office_code: 995_456,
                         provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code, clinician_address_id: clinician_address.id }, account_holder: account_holder, marketing_referral_id: "123")
      end
      let(:intake_address) { create(:intake_address, intake_addressable: patient) }
      let!(:skip_patient_amd) { skip_patient_amd_creation }
      let(:amd_child_patient) do
        Amd::Data::AmdPatient.new(child_patient)
      end

      it "should not returns email if patient is child" do
        expect(amd_child_patient.email).to eq("")
      end
    end
  end
end
