require "rails_helper"

RSpec.describe LicenseKeyRule, type: :model do
  describe "associations" do
    it { should belong_to(:license_key) }
    it { should belong_to(:ruleable) }
  end

  context ".scopes" do
    describe ".insurance_rule_skip_flag" do
      let!(:insurance_rule_skip_case) { create(:insurance_rule) }
      let!(:insurance_rule_mandatory_case) { create(:insurance_rule, skip_option_flag: false) }
      let!(:license_key) { create(:license_key) }
      let!(:license_key_rule) do
        create(:license_key_rule, license_key: license_key, rule_name: INSURANCE_SKIP_OPTION_RULE, ruleable_type: INSURANCERULE,
                                  ruleable_id: insurance_rule_skip_case.id)
      end

      it "returns the LicenseKeyRule object" do
        license_key_rule_object = LicenseKeyRule.insurance_rule_skip_flag(license_key.key)
        expect(license_key_rule_object).to include(license_key_rule)
      end
    end

    describe ".availablity_block_out_for_license_key" do
      let!(:availability_block_out_rule24) { create(:availability_block_out_rule, hours: 24) }
      let!(:availability_block_out_rule48) { create(:availability_block_out_rule, hours: 48) }
      let!(:license_key) { create(:license_key) }
      let!(:license_key_rule) do
        create(:license_key_rule, license_key: license_key, rule_name: AVAILABILITY_BLOCK_OUT_RULE, ruleable_type: "AvailabilityBlockOutRule",
                                  ruleable_id: availability_block_out_rule48.id)
      end

      it "returns the LicenseKeyRule record" do
        license_key_rule_object = LicenseKeyRule.availablity_block_out_for_license_key(license_key.key)
        expect(license_key_rule_object).to include(license_key_rule)
      end
    end
  end

  context "Class Methods" do
    describe ".get_insurance_rule_skip_flag" do
      let!(:insurance_rule_skip_case) { create(:insurance_rule) }
      let!(:insurance_rule_mandatory_case) { create(:insurance_rule, skip_option_flag: false) }
      let!(:license_key) { create(:license_key) }
      let!(:license_key_rule) do
        create(:license_key_rule, license_key: license_key, rule_name: INSURANCE_SKIP_OPTION_RULE, ruleable_type: INSURANCERULE,
                                  ruleable_id: insurance_rule_mandatory_case.id)
      end
      it "returns the skip skip_option_flag false" do
        insurance_skip_option_flag = LicenseKeyRule.get_insurance_rule_skip_flag(license_key.key)
        expect(insurance_skip_option_flag).to eq(false)
      end

      it "returns the skip skip_option_flag true default if key doesnot exist" do
        insurance_skip_option_flag = LicenseKeyRule.get_insurance_rule_skip_flag(996548)
        expect(insurance_skip_option_flag).to eq(true)
      end
    end

    describe ".block_out_hours_for_license_key" do
      let!(:availability_block_out_rule24) { create(:availability_block_out_rule, hours: 24) }
      let!(:availability_block_out_rule48) { create(:availability_block_out_rule, hours: 48) }
      let!(:license_key) { create(:license_key) }
      let!(:license_key_rule) do
        create(:license_key_rule, license_key: license_key, rule_name: AVAILABILITY_BLOCK_OUT_RULE, ruleable_type: "AvailabilityBlockOutRule",
                                  ruleable_id: availability_block_out_rule48.id)
      end


      it "returns the availability block out in hours" do
        expect(LicenseKeyRule.block_out_hours_for_license_key(license_key.key)).to eq(48)
      end

      it "returns 24 for the availability block out hour if one doesn't exist" do
        expect(LicenseKeyRule.block_out_hours_for_license_key(999999)).to eq(24)
      end
    end
  end
end
