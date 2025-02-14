require "rails_helper"

describe InsuranceCardUploadService, type: :class do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }
  let!(:patient) { create(:patient, amd_patient_id: 5_983_957, marketing_referral_id: 123) }
  let!(:insurance) { create(:insurance) }
  let!(:clinician) { create(:clinician) }
  let!(:address) { create(:clinician_address, clinician: clinician) }
  let!(:facility_accepted_insurance) do
    create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)
  end
  let!(:responsible_party) { create(:responsible_party) }
  let!(:insurance_coverage) do
    create(:insurance_coverage, patient: patient, policy_holder: responsible_party, relation_to_policy_holder: "self")
  end
  let(:image1) { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "test1.png")) }
  let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }

  let(:insurance_card_service) { InsuranceCardUploadService.new(insurance_coverage, { front_card: image1 }) }

  describe ".save" do
    it "uploads the front card image for insurance coverage" do
      expect(insurance_coverage.front_card_url).to eq(nil)
      Sidekiq::Testing.inline! do
        VCR.use_cassette("amd/upload_insurance_card_file_to_amd_success") do
          insurance_card_service.save
        end
      end
      insurance_coverage.reload
      expect(insurance_coverage.front_card_url).to_not be(nil)
      expect(insurance_coverage.front_card_url).to match("#{Rails.application.credentials.host_url}/rails/active_storage/disk")
    end
  end

  describe ".save_file_to_s3" do
    it "returns the uploadable file blob id" do
      blob_id = insurance_card_service.send(:save_file_to_s3, "front_card")

      expect(blob_id).to_not eq(nil)
    end
  end
end
