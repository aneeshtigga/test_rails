require "rails_helper"

describe LicenseKeyBlockoutRule, type: :class do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday

  before do
    travel_to stub_time
  end

  after do
    travel_back
  end

  let!(:clinician) { create(:clinician) }
  let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 25.hours) }

  describe "#passes_for?" do
    context "when the license key has a 48hr blocked out" do
      it "returns false" do
        allow(LicenseKeyRule).to receive(:block_out_hours_for_license_key).and_return(48)
        
        expect(LicenseKeyBlockoutRule.passes_for?(appointment)).to be false
      end
    end

    context "when the license key has a 24hr blocked out" do
      it "returns true" do
        allow(LicenseKeyRule).to receive(:block_out_hours_for_license_key).and_return(24)

        expect(LicenseKeyBlockoutRule.passes_for?(appointment)).to be true
      end
    end

    context "when the license key has no blocked out" do
      it "returns true" do
        allow(LicenseKeyRule).to receive(:block_out_hours_for_license_key).and_return(0)

        expect(LicenseKeyBlockoutRule.passes_for?(appointment)).to be true
      end
    end
  end
end
