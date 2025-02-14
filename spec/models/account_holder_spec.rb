require "rails_helper"

RSpec.describe AccountHolder, type: :model do
  describe "associations" do
    it { should belong_to(:responsible_party).optional }
    it { should have_many(:intake_addresses) }
    it { should have_many(:patients) }
  end

  describe "validations" do
    context "presence validations" do
      it { should validate_presence_of(:first_name) }
      it { should validate_presence_of(:last_name) }
      it { should validate_presence_of(:email) }
      it { should validate_presence_of(:date_of_birth) }
      it { should validate_presence_of(:gender) }
      it { should validate_presence_of(:phone_number) }
    end
  end

  describe "#amd_respparty_id" do
    it "returns the responsible party amd_id" do
      responsible_party = create(:responsible_party, amd_id: "123")
      account_holder = create(:account_holder, responsible_party: responsible_party)

      expect(account_holder.amd_respparty_id).to eq("123")
    end
  end

  describe "#self_patient" do
    it "returns patient record where account holder relation is self" do
      skip_patient_amd_creation

      account_holder = create(:account_holder)
      patient = create(:patient, account_holder: account_holder, account_holder_relationship: :self)
    end

    it "returns nil if patient record is not found" do
      skip_patient_amd_creation

      account_holder = create(:account_holder)
      patient = create(:patient, account_holder: account_holder, account_holder_relationship: :child)
    end
  end
end
