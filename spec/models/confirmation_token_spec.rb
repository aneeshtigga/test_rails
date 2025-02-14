require "rails_helper"

RSpec.describe ConfirmationToken, type: :model do
  describe "associations" do
    it { should belong_to(:account_holder) }
  end

  describe "random token generation" do
    it { should have_secure_token(:token) }
  end

  describe "validations" do
    let!(:token) { create(:confirmation_token) }
    it { should validate_uniqueness_of(:token) }
  end

  describe ".active?" do
    let!(:token) { create(:confirmation_token) }

    it "returns true if token didn't expire" do
      expect(token.expire_at).to be > Time.now
      expect(token.active?).to be true
    end

    it "returns true if token didn't expire" do
      token.update(expire_at: Time.now - 1.minutes)
      token.reload

      expect(token.active?).to be false
    end
  end

  describe ".set_expiry" do
    let!(:token) { create(:confirmation_token) }

    it "sets the expiry for the token" do
      token.update(expire_at: Time.now - 1.minutes)
      token.reload

      expect(token.active?).to be false
      token.set_expiry
      expect(token.active?).to be true
    end
  end
end
