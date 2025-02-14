require "rails_helper"

RSpec.describe HipaaRelationshipCode, type: :model do
  describe "validations" do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:description) }
  end

  describe "default values" do
    it "will have active field default to true" do
      hipaa_relationship_code = create(:hipaa_relationship_code)
      expect(hipaa_relationship_code.active).to be true
      expect(hipaa_relationship_code.code).to be 1
      expect(hipaa_relationship_code.description).to eq "MyString"
    end
  end
end
