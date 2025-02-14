require "rails_helper"

RSpec.describe Amd::Api::AccountHolderApi, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let(:config) do
    Amd::AmdConfiguration.setup do |config|
      config.request_endpoint = "xmlrpc/processrequest.aspx"
    end
  end

  let!(:clinician_address) { create(:clinician_address) }

  let!(:authenticate_amd) do
    VCR.use_cassette("amd/authenticate_amd") do
      Amd::AmdClient.new(office_code: 995456).authenticate 
    end
  end

  let(:base_url) { authenticate_amd[0] }
  let(:token) { authenticate_amd[1] }
  let(:account_holder_api) { Amd::Api::AccountHolderApi.new(config, base_url, token) }
  let(:params) do
    {
      full_name: "blackbeard,captain",
      email: "blackbeardctest@email.com"
    }
  end

  describe "#save_account" do

    context "when the account is created in amd" do
      it "id, fullname and email address are returned in the response" do
        VCR.use_cassette("amd/save_account_success") do
          account = account_holder_api.save_account(params)

          expect(account).to include(
            "@fullname" => params[:full_name],
            "@emailaddress" => params[:email]
          )
        end
      end
    end

    context "when the account creation fails in amd" do
      it "Error key is present in the response" do
        VCR.use_cassette("amd/save_account_fails") do
          response = account_holder_api.save_account(params)

          expect(response["Fault"].present?).to be_truthy
        end
      end
    end
  end
end
