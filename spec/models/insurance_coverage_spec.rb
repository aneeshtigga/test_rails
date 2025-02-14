require "rails_helper"

RSpec.describe InsuranceCoverage, type: :model do
  describe "associations" do
    it { should belong_to(:policy_holder) }
    it { should belong_to(:facility_accepted_insurance).optional }
  end

  context "validations" do
    it { should validate_presence_of(:company_name) }
    it { should validate_presence_of(:member_id) }
    it { should validate_presence_of(:relation_to_policy_holder) }
    it { should validate_inclusion_of(:relation_to_policy_holder).in_array(%w[self spouse parent_guardian child other]) }
  end
end
