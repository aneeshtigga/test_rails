require "rails_helper"

RSpec.describe MarketingReferral, type: :model do

  describe "validations" do
    it { should validate_presence_of(:display_marketing_referral) }
    it { should validate_presence_of(:amd_marketing_referral) }
  end
  
end
