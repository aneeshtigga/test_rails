require "rails_helper"

RSpec.describe FacilityAcceptedInsurance, type: :model do
  describe "validations" do
    it { should validate_presence_of(:insurance_id) }
  end

  describe "associations" do
    it { should belong_to(:insurance) }
    it { should belong_to(:clinician_address) }
    it { should belong_to(:clinician) }
    it { should have_many(:insurance_coverages)}
  end

  context "scopes" do
    describe ".with_insurance_name" do
      it "filters facility_accepted_insurance by insurance name" do
        insurance = create(:insurance)
        clinician = create(:clinician)
        address = create(:clinician_address,clinician: clinician)
        facility_accepted_insurance = create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)
        expect(FacilityAcceptedInsurance.with_insurance_name("Florida Blues")).to match_array([facility_accepted_insurance])
      end
    end

    describe ".with_clinician_address" do
      it "filters facility_accepted_insurance by provider id, facility id and license key" do
        insurance = create(:insurance)
        clinician = create(:clinician)
        address = create(:clinician_address,clinician: clinician)
        facility_accepted_insurance = create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)
        expect(FacilityAcceptedInsurance.with_clinician_address(1, 995456, 1)).to match_array([facility_accepted_insurance])
      end
    end
  end
end
