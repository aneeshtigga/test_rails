require "rails_helper"

RSpec.describe Amd::Data::FamilyMember, type: :class do
  let(:family_member_address_data) do
    {
      "@zip" => "02151-1234"
    }
  end

  let(:amd_family_member_data) do
    {
      "@id" => "12345",
      "@name" => "JACK,CAPTAIN",
      "@chart" => "123",
      "@isrp" => "1",
      "address" => family_member_address_data
    }
  end

  let(:family_member) { Amd::Data::FamilyMember.new(amd_family_member_data) }

  describe "#initialize" do
    it "sets the data attribute" do
      expect(family_member.data.to_h.keys).to match(amd_family_member_data.keys.map(&:to_sym))
    end
  end

  describe '#id' do
    it "returns the @id value" do
      expect(family_member.id).to eq(amd_family_member_data["@id"])
    end
  end

  describe '#name' do
    it "returns the @name value" do
      expect(family_member.name).to eq(amd_family_member_data["@name"])
    end
  end

  describe '#last_name' do
    it "returns the @last_name value" do
      expect(family_member.last_name).to eq("JACK")
    end
  end

  describe '#first_name' do
    it "returns the @first_name value" do
      expect(family_member.first_name).to eq("CAPTAIN")
    end
  end

  describe '#chart' do
    it "returns the @chart value" do
      expect(family_member.chart).to eq("123")
    end
  end

  describe '#responsible_party?' do
    it "returns the true if value is 1" do
      expect(family_member.responsible_party?).to be true
    end
  end
  describe '#zip_code' do
    it "returns the @dob value" do
      expect(family_member.zip_code).to eq("02151")
    end
  end

  describe "Address" do
    describe '#address' do
      it "returns an Amd::Data::Address object" do
        expect(family_member.address).to be_an_instance_of(Amd::Data::Address)
      end
    end
  end
end
