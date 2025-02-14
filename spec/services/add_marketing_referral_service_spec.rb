require "rails_helper"

describe AddMarketingReferralService, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let!(:clinician_address) { create(:clinician_address) }
  let(:patient) do 
    skip_patient_amd_creation

    create(:patient, first_name: "test", amd_patient_id: 5983942)
  end

  describe ".amd_source_id" do
    it "returns the AMD source id mapped to patients referral source" do
      skip_referral_amd_creation

      marketing_referral_service = AddMarketingReferralService.new(patient)
      expect(marketing_referral_service.amd_source_id).to_not be nil
    end
  end

  describe ".push_referral" do
    it "posts the marketing referral source associated to patient" do
      skip_referral_amd_creation

      marketing_referral_service = AddMarketingReferralService.new(patient)
      expect(marketing_referral_service.push_referral).to be true
      expect(patient.reload.marketing_referral_id).to_not be nil
    end
  end

end
