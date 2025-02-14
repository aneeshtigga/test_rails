require 'rails_helper'

RSpec.describe ResponsibleParty, type: :model do
  describe "associations" do
    it { should have_many(:insurance_coverages) }
    it { should have_one(:intake_address) }
    it { should have_one(:account_holder) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:gender) }
    it { should validate_presence_of(:email) }
  end
end
