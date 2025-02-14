require "rails_helper"

RSpec.describe Heartland::Client, type: :class do

  describe "#intialize" do
    it "sets the config" do
      expected_config = {
        api_key: 123456,
        url: "https://cert.api2.heartlandportico.com/Hps.Exchange.PosGateway.Hpf.v1/api/token?api_key=123456",
      }

      expect(Heartland::Client.new(api_key: 123456).config).to eq expected_config
    end
  end

  describe "#get_token" do
    it "returns a token" do
      cc_data = {
        number: 4111_1111_1111_1111,
        cvc: "123",
        exp_month: "12",
        exp_year: "2025"
      }
      
      response = double
      allow(response).to receive(:body).and_return({ "token_value" => "ab6dbba6" }.to_json)
      expect(RestClient).to receive(:post)
        .with(anything, anything, Heartland::Client.headers)
        .once
        .and_return(response)

      client = Heartland::Client.new(api_key: 123456)
      expect(client.get_token(cc_data)).to be_an_instance_of(String)
    end
  end

  describe ".headers" do
    it "returns the headers" do
      expect(Heartland::Client.headers).to eq({
        accept: :json,
        content_type: "application/json",
      })
    end
  end
end
