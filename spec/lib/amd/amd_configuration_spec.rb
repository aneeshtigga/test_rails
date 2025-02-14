require "rails_helper"

RSpec.describe Amd::AmdConfiguration, type: :class do
  let!(:clinician_address) { create(:clinician_address) }
  describe ".setup" do
    it "initializes a new configuration" do
      config = Amd::AmdConfiguration.setup do |config|
        config.app_name = "lifestance1"
      end

      expect(config.app_name).to eq("lifestance1")
    end
  end

  describe ".user_name_password_for_license_key" do
    it "returns the correct cbo login credentials for office key" do
      expect(Amd::AmdConfiguration.user_name_password_for_cbo(149330).keys).to eq(
        [
          :user_name,
          :password
        ]
      )
    end
  end
end
