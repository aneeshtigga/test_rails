require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    context "presence validations" do
      it { should validate_presence_of(:first_name) }
      it { should validate_presence_of(:last_name) }
      it { should validate_presence_of(:email) }
    end
  end

  describe "#saml?" do
    it "returns true if a saml_uid exists" do
      user = create(:user, saml_uid: 12345)

      expect(user.saml?).to be_truthy
    end

    it "returns false if saml_uid does not exist" do
      user = create(:user)
      
      expect(user.saml?).to be_falsey
    end
  end

  describe "#admin?" do
    # for now all users are admin users
    it "returns true" do
      user = create(:user)

      expect(user.admin?).to be_truthy
    end
  end

end
