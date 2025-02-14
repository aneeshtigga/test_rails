require "rails_helper"

RSpec.describe Amd::AmdClient, type: :class do
  before :all do 
    create(:license_key, 
      key:    995456,
      cbo:    149330,
      active: true)
  end

  describe "#intialize" do
    it "sets the config" do
      VCR.use_cassette('authenticate_user') do
        config = Amd::AmdConfiguration.config_for_office_key(995456)

        expect(Amd::AmdClient.new(office_code: 995456).config.app_name).to eq(config.app_name)
      end
    end
  end

  describe "#find_or_create_session" do
    it "successfully authenticates the user" do
      VCR.use_cassette('authenticate_user') do
        client = Amd::AmdClient.new(office_code: 995456)
      end
    end

    it "retrieves a session if one exists within the last day" do
      session = create(:amd_api_session, office_code: 995456, token: "secret")

      client = Amd::AmdClient.new(office_code: 995456)

      expect(client.token).to eq("secret")
    end
  end

  describe "#patients" do
    it "returns an new instance of PatientsApi" do
      session = create(:amd_api_session, office_code: 995456, token: "secret")

      client = Amd::AmdClient.new(office_code: 995456)
      expect(client.patients).to be_an_instance_of(Amd::Api::PatientApi)
    end
  end


  describe "#add_insurance" do
    it "returns an new instance of InsuranceApi" do
      session = create(:amd_api_session, office_code: 995456, token: "secret")

      client = Amd::AmdClient.new(office_code: 995456)
      expect(client.insurances).to be_an_instance_of(Amd::Api::InsuranceApi)
    end
  end

  describe "#responsible_parties" do
    it "returns an new instance of PatientsApi" do
      session = create(:amd_api_session, office_code: 995456, token: "secret")

      client = Amd::AmdClient.new(office_code: 995456)

      expect(client.responsible_parties).to be_an_instance_of(Amd::Api::ResponsiblePartyApi)
    end
  end

  describe "#referrals" do
    it "returns an new instance of ReferralApi" do
      session = create(:amd_api_session, office_code: 995456, token: "secret")

      client = Amd::AmdClient.new(office_code: 995456)

      expect(client.referrals).to be_an_instance_of(Amd::Api::ReferralApi)
    end
  end

  describe "#transactions" do
    it "returns an new instance of ReferralApi" do
      session = create(:amd_api_session, office_code: 995456, token: "secret")

      client = Amd::AmdClient.new(office_code: 995456)

      expect(client.transactions).to be_an_instance_of(Amd::Api::TransactionsApi)
    end
  end

  describe "#custom_data" do
    it "returns an new instance of CustomDataApi" do
      session = create(:amd_api_session, office_code: 995456, token: "secret")

      client = Amd::AmdClient.new(office_code: 995456)

      expect(client.custom_data).to be_an_instance_of(Amd::Api::CustomDataApi)
    end
  end
end
