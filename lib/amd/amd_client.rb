require "rest-client"

module Amd
  class AmdClient
    attr_reader :config
    attr_reader :redirect_url
    attr_reader :token
    attr_reader :office_code

    def initialize(office_code:)
      @config = Amd::AmdConfiguration.config_for_office_key(office_code)
      @office_code = office_code

      find_or_create_session
    end

    def authenticate
      login_url = config.login_url

      payload = {
        ppmdmsg: {
          '@action': "login",
          '@class': "login",
          '@username': config.user_name,
          '@psw': config.password,
          '@officecode': config.office_code,
          '@appname': config.app_name
        }
      }.to_json

      resp = RestClient.post(login_url, payload, default_headers)
      json_resp = JSON.parse(resp.body)

      redirect_url = json_resp.dig("PPMDResults", "Results", "usercontext", "@webserver")
      endpoint = "xmlrpc/processrequest.aspx"
      url = "#{redirect_url}/#{endpoint}"

      success_flag = json_resp.dig("PPMDResults", "Results", "@success")
      error_fault = json_resp.dig("PPMDResults", "Error", "Fault", "detail", "code")

      if (error_fault == "-2147220476" && success_flag == "0")
        resp = RestClient.post(url, payload, default_headers)
        json_resp = JSON.parse(resp.body)
      end

      token = json_resp.dig("PPMDResults", "Results", "usercontext", "#text")

      raise "URGENT: AMD did not respond with a token. Response: #{json_resp.dig("PPMDResults").to_s}" unless token

      [redirect_url, token]
    end

    def find_or_create_session
      last_session = AmdApiSession.by_office_code(office_code).last_active_session

      if last_session.present?
        @redirect_url = last_session.redirect_url
        @token = last_session.token
      else
        @redirect_url, @token = authenticate

        AmdApiSession.create!(
          office_code: config.office_code,
          redirect_url: @redirect_url,
          token: @token
        )
      end
    end

    def patients
      @patients ||= Amd::Api::PatientApi.new(config, base_url, token)
    end

    def custom_data
      @custom_data ||= Amd::Api::CustomDataApi.new(config, base_url, token)
    end

    def responsible_parties
      @responsible_parties ||= Amd::Api::ResponsiblePartyApi.new(config, base_url, token)
    end

    def insurances
      @insurance ||= Amd::Api::InsuranceApi.new(config, base_url, token)
    end

    def appointments
      config.request_endpoint = nil
      base_url = config.scheduler_request_url.gsub("{api_version}", "#{amd_api_version}")
      @appointments ||=  Amd::Api::AppointmentApi.new(config, base_url, token)
    end

    def auto_assign_forms
      config.request_endpoint = "xmlrpc/processrequest.aspx"
      # base_url = "https://providerapi.advancedmd.com/processrequest/API-102/LIFESTANCE"
      @auto_assign_forms ||=  Amd::Api::AutoAssignFormsApi.new(config, base_url, token)
    end

    def episodes
      @episodes ||= Amd::Api::GetEpisodesApi.new(config, base_url, token)
    end

    def referrals
      @referrals ||= Amd::Api::ReferralApi.new(config, base_url, token)
    end

    def upload_files
      @upload_files ||= Amd::Api::UploadFileApi.new(config, base_url, token)
    end

    def account_holders
      @account_holders ||= Amd::Api::AccountHolderApi.new(config, base_url, token)
    end

    def transactions
      config.request_endpoint = ""
      base_url = "https://providerapi.advancedmd.com/api/#{amd_api_version}/#{config.app_name}/transaction"
      @transactions ||= Amd::Api::TransactionsApi.new(config, base_url, token)
    end

    private

    def default_headers
      {
        accept: :json,
        content_type: "application/json"
      }
    end

    def base_url
      "#{redirect_url}/#{config.request_endpoint}"
    end

    def amd_api_version
      session = AmdApiSession.last
      redirect_url = session.redirect_url
      api_version = redirect_url.split("/")[-2]
    end
  end
end
