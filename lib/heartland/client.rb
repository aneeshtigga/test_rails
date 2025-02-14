require "rest-client"

module Heartland
  class Client
    attr_accessor :config

    BASE_URL = "https://cert.api2.heartlandportico.com/Hps.Exchange.PosGateway.Hpf.v1/".freeze

    # RestClient.log = 'stdout' # uncomment this line to see the request headers and body in the console

    def initialize(api_key:)
      self.config = {
        api_key: api_key,
        url: "#{BASE_URL}api/token?api_key=#{api_key}",
      }
    end

    def get_token(cc_data)
      payload = {
        object: "token",
        token_type: "supt",
        card: cc_data,
      }
      
      begin
        resp = RestClient.post(config[:url], payload.to_json, Heartland::Client.headers)

        json_resp = JSON.parse(resp.body)
        json_resp&.dig("token_value")
      rescue StandardError => e
        ErrorLogger.report(e)
      end
      
    end

    def self.headers
      {
        accept: :json,
        content_type: "application/json",
      }
    end
  end
end
