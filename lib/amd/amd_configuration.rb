module Amd
  class AmdConfiguration
    attr_accessor :login_url
    attr_accessor :user_name
    attr_accessor :password
    attr_accessor :office_code
    attr_accessor :app_name
    attr_accessor :request_endpoint
    attr_accessor :scheduler_request_url
    attr_accessor :referral_request_url
    attr_accessor :referral_endpoint
    attr_accessor :ehr_file_upload_url

    def self.setup
      new.tap do |config|
        yield(config) if block_given?
      end
    end

    def self.config_for_office_key(office_code)
      cbo = LicenseKey.find_by(key: office_code)&.cbo

      raise "cbo mapping missing for the office code" if cbo.nil?

      config_for_cbo = user_name_password_for_cbo(cbo)


      raise "license key configuration not found" if config_for_cbo.nil?

      setup do |config|
        config.login_url = Rails.application.credentials.amd[:login_url]
        config.app_name = Rails.application.credentials.amd[:app_name]
        config.request_endpoint = Rails.application.credentials.amd[:request_endpoint]
        config.scheduler_request_url = Rails.application.credentials.amd[:scheduler_request_url]
        config.user_name = config_for_cbo[:user_name]
        config.password = config_for_cbo[:password]
        config.office_code = office_code
        config.referral_request_url = Rails.application.credentials.amd[:referral_request_url]
        config.referral_endpoint = Rails.application.credentials.amd[:referral_endpoint]
        config.ehr_file_upload_url = Rails.application.credentials.amd[:ehr_file_upload_url]
      end
    end

    def self.user_name_password_for_cbo(cbo)
      api_credentials = Rails.application.credentials.amd[:cbo_logins][cbo.to_i]

      {
        user_name: api_credentials[:user_name],
        password: api_credentials[:password]
      }
    end

    def initialize
      @login_url = Rails.application.credentials.amd[:login_url]
      @app_name = Rails.application.credentials.amd[:app_name]
      @request_endpoint = Rails.application.credentials.amd[:request_endpoint]
      @scheduler_request_url = Rails.application.credentials.amd[:scheduler_request_url]
      @ehr_file_upload_url = Rails.application.credentials.amd[:ehr_file_upload_url]
    end
  end
end
