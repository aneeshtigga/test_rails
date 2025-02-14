require "rails_helper"

RSpec.describe Amd::Data::Address, type: :class do
  let(:patient_address_data) do
    {
      "@zip" => "02151-1234"
    }
  end

  let(:address) { Amd::Data::Address.new(patient_address_data) }

  describe "#initialize" do
    it "sets the data attribute" do
      expect(address.data.to_h.keys).to match(patient_address_data.keys.map(&:to_sym))
    end
  end

  describe '#zip_code' do
    it "returns the @zip value" do
      expect(address.zip_code).to eq("02151")
    end
  end
end
