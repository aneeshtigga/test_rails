require "rails_helper"

RSpec.describe Amd::Data::ResponsibleParty, type: :class do
  let(:address_data) do
    {
      "@zip" => "02151-1234"
    }
  end

  let(:amd_responsible_party_data) do
    {
      "@id" => "12345",
      "@name" => "JACK,CAPTAIN",
      "@dob" => "01/01/1992",
      "address" => address_data,
      "@gender" => "male",
      "@email" => "email",
    }
  end

  let(:responsible_party) { Amd::Data::ResponsibleParty.new(amd_responsible_party_data) }

  describe "#initialize" do
    it "sets the data attribute" do
      expect(responsible_party.data.to_h.keys).to match(amd_responsible_party_data.keys.map(&:to_sym))
    end
  end

  describe '#id' do
    it "returns the @id value" do
      expect(responsible_party.id).to eq(amd_responsible_party_data["@id"])
    end
  end

  describe '#name' do
    it "returns the @name value" do
      expect(responsible_party.name).to eq(amd_responsible_party_data["@name"])
    end
  end

  describe "#acct_num" do
    it "returns the @acct_num value" do
      expect(responsible_party.acct_num).to eq(amd_responsible_party_data["@acct_num"])
    end
  end

  describe '#last_name' do
    it "returns the @last_name value" do
      expect(responsible_party.last_name).to eq("JACK")
    end
  end

  describe '#first_name' do
    it "returns the @first_name value" do
      expect(responsible_party.first_name).to eq("CAPTAIN")
    end
  end

  describe '#date_of_birth' do
    it "returns the @dob value" do
      expect(responsible_party.date_of_birth).to eq(amd_responsible_party_data["@dob"])
    end
  end

  describe '#zip_code' do
    it "returns the @dob value" do
      expect(responsible_party.zip_code).to eq("02151")
    end
  end

  describe '#gender' do
    it "returns the @gender value" do
      expect(responsible_party.gender).to eq("male")
    end
  end

  describe '#email' do
    it "returns the @email value" do
      expect(responsible_party.email).to eq("email")
    end
  end

  describe "Address" do
    describe '#address' do
      it "returns an Amd::Data::Address object" do
        expect(responsible_party.address).to be_an_instance_of(Amd::Data::Address)
      end
    end
  end
end
