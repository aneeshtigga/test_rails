require "rails_helper"

RSpec.describe InsuranceRule, type: :model do
  describe "associations" do
    it { should have_many(:license_key_rules) }
  end
end
