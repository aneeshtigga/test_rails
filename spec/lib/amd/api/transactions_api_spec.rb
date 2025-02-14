require "rails_helper"
require "#{Rails.root}/spec/support/mocks_and_stubs/amd_api_baseapi_stub"

RSpec.describe Amd::Api::TransactionsApi, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let!(:clinician_address) { create(:clinician_address) }
  let(:transactions_api) do
    amd_config = Amd::AmdConfiguration.setup { |config| config.request_endpoint = "" }
    Amd::Api::TransactionsApi.new(amd_config, authenticate_amd(102).base_url, authenticate_amd(102).token)
  end
  let(:responsible_party) { create(:responsible_party, amd_id: "123456") }
  let(:account_holder) { create(:account_holder, responsible_party: responsible_party) }
  let(:patient) do
    create(:patient, amd_patient_id: 5_983_942, office_code: 995_456, provider_id: 123,
            account_holder: account_holder)
  end

  describe "#merchant_accounts" do
    it "returns a list of AMD merchant accounts" do
      url = "https://provapi.advancedmd.com/processrequest/api-102/LIFESTANCE/payment/accounts"
      expected_response = [{
        "accountName"=>"Card Not Present",
        "publicApiKey"=>"pkapi_cert_oNZSgK9u579B60W6rd",
        "secondaryPublicApiKey"=>nil,
        "secretApiKey"=>"skapi_cert_MXE2AgDxzWEAIkFJoyjyKGljL8iuLVtzaSpT1zoZ1g",
        "accountToken"=>nil,
        "paymentProcessor"=>1,
        "display"=>true,
        "paymentProcessingAccountId"=>nil,
        "id"=>2,
      }]

      allow(ApiLogWorker).to receive(:perform_async).with(anything)

      response = double
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return(expected_response.to_json)
      allow(response).to receive(:net_http_res).and_return(OpenStruct.new(message: ""))
      allow(RestClient).to receive(:get).with(url, anything).and_return(response)

      expect(transactions_api.merchant_accounts).to eq expected_response
      expect(RestClient).to have_received(:get).with(url, anything).once
      expect(ApiLogWorker).to have_received(:perform_async).with(anything).once
    end
  end

  describe "#merchant_account" do
    it "returns nil if there are no merchant accounts" do
      allow(transactions_api).to receive(:merchant_accounts).and_return([])

      expect(transactions_api.merchant_account("abc")).to be_nil
    end

    it "returns the correct merchant account" do
      expected_result = { "accountName"=>"Card Not Present", "publicApiKey"=>"abc123", "id"=>1}
      merchant_accounts = [
        { "accountName"=>"Card Not Present", "publicApiKey"=>"abc123", "id"=>1},
        { "accountName"=>"Card Present", "publicApiKey"=>"abc111", "id"=>2}
      ]
      allow(transactions_api).to receive(:merchant_accounts).and_return(merchant_accounts)

      expect(transactions_api.merchant_account("Card Not Present")).to eq expected_result
    end
  end

  describe "#credit_card_on_file?" do
    it "returns true if there is a credit card on file" do
      credit_cards_on_file = [
        { "name"=>"Credit card on file", "id"=>2, },
        { "name"=>"Other credit card", "id"=>1, }
      ]

      allow(ApiLogWorker).to receive(:perform_async).with(anything)

      response = double
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return(credit_cards_on_file.to_json)
      allow(response).to receive(:net_http_res).and_return(OpenStruct.new(message: ""))
      allow(RestClient).to receive(:get).with(anything, anything).and_return(response)

      expect(transactions_api.credit_card_on_file?(123)).to eq true
      expect(ApiLogWorker).to have_received(:perform_async).with(anything).once
    end

    it "returns false if the name does not match" do
      credit_cards_on_file = [
        { "name"=>"Different card on file", "id"=>2, },
        { "name"=>"Other credit card", "id"=>1, }
      ]

      allow(ApiLogWorker).to receive(:perform_async).with(anything)

      response = double
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return(credit_cards_on_file.to_json)
      allow(response).to receive(:net_http_res).and_return(OpenStruct.new(message: ""))
      allow(RestClient).to receive(:get).with(anything, anything).and_return(response)

      expect(transactions_api.credit_card_on_file?(123)).to eq false
      expect(ApiLogWorker).to have_received(:perform_async).with(anything).once
    end

  end

  describe "#add_credit_card" do
    it "posts data for credit card on file to AMD" do
      credit_card_params = {
        creditCardToken: "token_123",
        lastFourDigits: "1111",
        expirationMonth: 12,
        expirationYear: 2025,
        zipCode: "75024",
        responsiblePartyId: 111,    
      }

      response = double
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return({ "id" => 111 }.to_json)
      allow(response).to receive(:net_http_res).and_return(OpenStruct.new(message: ""))

      expect(transactions_api).to receive(:merchant_account).with(Amd::Api::TransactionsApi::MERCHANT_ACCOUNT_NAME)
                                                            .once
                                                            .and_return({"id" => 123})
      expect(RestClient).to receive(:post)
        .with(anything, anything, transactions_api.send(:bearer_token_request_headers))
        .once
        .and_return(response)

      expect(transactions_api.add_credit_card(credit_card_params)).to eq true
    end
  end

end
