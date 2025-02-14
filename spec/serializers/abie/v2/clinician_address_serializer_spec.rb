require "rails_helper"

RSpec.describe Abie::V2::ClinicianAddressSerializer, type: :request do
  describe "Serializer transforms data" do
    let!(:postal_code) { create(:postal_code) }

    before(:each) do
      @clinician_address = FactoryBot.create(:clinician_address, :with_clinician_availability)
      @insurance = FactoryBot.create(:insurance)
      @facility_accepted_insurance = FactoryBot.create(:facility_accepted_insurance,
        clinician_address_id: @clinician_address.id, insurance_id: @insurance.id)
      @serializer = Abie::V2::ClinicianAddressSerializer.new(@clinician_address)
      @serialization = ActiveModelSerializers::Adapter.create(@serializer)
    end

    subject { JSON.parse(@serialization.to_json) }

    let(:clinician_address_no_insurance)  {create(:clinician_address, :with_clinician_availability)}
    let(:serializer_no_insurance) {Abie::V2::ClinicianAddressSerializer.new(:clinician_address_no_insurance)}
    let(:serialization_no_insurance) {ActiveModelSerializers::Adapter.create(:serializer_no_insurance)}
    let(:serialization) { JSON.parse(:serialization_no_insurance.to_json) }
    it "returns a supervised insurance inside the serializer data but empty" do
      expect(:serialization['supervised_insurances']).to be_blank
    end

    it "returns a supervised insurance inside the serializer data with valid data" do
      insurances = @clinician_address.insurances.where.not(facility_accepted_insurances: { supervisors_name: nil }).pluck(:id, :name).uniq
      # Id name key value pair to front end
      keys = %w[id name]
      supervised_insurances = insurances.map { |v| keys.zip v }.map(&:to_h)
      expect(subject['supervised_insurances']).to eql(supervised_insurances)
    end
  end
end