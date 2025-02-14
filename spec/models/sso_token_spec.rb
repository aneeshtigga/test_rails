require 'rails_helper'

RSpec.describe SsoToken, type: :model do
  describe "random token generation" do
    it { should have_secure_token(:token) }
  end

  describe ".active?" do
    let!(:token) { create(:sso_token) }

    it "returns true if token is still valid" do
      expect(token.expire_at).to be > Time.now
      expect(token.active?).to be true
    end

    it "returns false if token is expired" do
      token.update(expire_at: Time.now - 1.minutes)
      token.reload

      expect(token.active?).to be false
    end
  end
end
