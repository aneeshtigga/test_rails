require "rails_helper"

RSpec.describe AddressType, type: :model do
  describe "validations" do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:description) }
  end

  describe "default values" do
    it "will have active field default to true" do
      address_type = create(:address_type)
      expect(address_type.active).to be true
      expect(address_type.code).to be 1
      expect(address_type.description).to eq "MyString"
    end
  end
end
