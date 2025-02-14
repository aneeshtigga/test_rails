require "rails_helper"

RSpec.describe Amd::Data::Patient, type: :class do
  let(:patient_address_data) do
    {
      "@zip" => "02151-1234"
    }
  end

  let(:amd_patient_data) do
    {
      "@id" => "12345",
      "@name" => "JACK,CAPTAIN",
      "@dob" => "01/01/1992",
      "address" => patient_address_data,
      "@gender" => "male",
      "@email" => "email",
    }
  end

  let(:patient) { Amd::Data::Patient.new(amd_patient_data) }

  describe "#initialize" do
    it "sets the data attribute" do
      expect(patient.data.to_h.keys).to match(amd_patient_data.keys.map(&:to_sym))
    end
  end

  describe '#id' do
    it "returns the @id value" do
      expect(patient.id).to eq(amd_patient_data["@id"])
    end
  end

  describe '#name' do
    it "returns the @name value" do
      expect(patient.name).to eq(amd_patient_data["@name"])
    end
  end

  describe '#last_name' do
    it "returns the @last_name value" do
      expect(patient.last_name).to eq("JACK")
    end
  end

  describe '#first_name' do
    it "returns the @first_name value" do
      expect(patient.first_name).to eq("CAPTAIN")
    end
  end

  describe '#date_of_birth' do
    it "returns the @dob value" do
      expect(patient.date_of_birth).to eq(amd_patient_data["@dob"])
    end
  end

  describe '#zip_code' do
    it "returns the @dob value" do
      expect(patient.zip_code).to eq("02151")
    end
  end

  describe '#gender' do
    it "returns the @gender value" do
      expect(patient.gender).to eq("male")
    end
  end

  describe '#email' do
    it "returns the @email value" do
      expect(patient.email).to eq("email")
    end
  end

  describe "Address" do
    describe '#address' do
      it "returns an Amd::Data::Address object" do
        expect(patient.address).to be_an_instance_of(Amd::Data::Address)
      end
    end
  end
end
