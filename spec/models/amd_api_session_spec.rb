require 'rails_helper'

RSpec.describe AmdApiSession, type: :model do
  describe "validations" do
    it { should validate_presence_of(:office_code) }
    it { should validate_presence_of(:redirect_url) }
    it { should validate_presence_of(:token) }
  end

  describe ".by_office_code" do
    it "returns sessions matching office code" do
      matching_session = create(:amd_api_session, office_code: 12345)
      non_matching_session = create(:amd_api_session, office_code: 54321)

      expect(AmdApiSession.by_office_code(12345)).to eq([matching_session])
    end
  end

  describe ".last_active_session" do
    it "returns sessions within the last day" do
      matching_session = create(:amd_api_session)
      non_matching_session = create(:amd_api_session,
        created_at: Time.zone.now - 1.day,
        updated_at: Time.zone.now - 1.day)

      expect(AmdApiSession.last_active_session).to eq(matching_session)
    end
  end
end
