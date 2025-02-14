Bugsnag.configure do |config|
  config.api_key = Rails.application.credentials.bugsnag_api_key

  filter_http_post_params = proc do |report|
    def sensitive_urls
      %w[/api/v1/account_holders /api/v1/patients/ /api/v1/patients/6099/patient_addresses
      /api/v1/patients/emergency_contact]
    end

    if ((request = report.meta_data[:request]) && ( request[:httpMethod] == 'POST' || request[:httpMethod] == 'PUT' ||
      request[:httpMethod] == 'PATCH' ))
      request[:params] = '[FILTERED]' if sensitive_urls.any? { |url| request[:url].include?(url) }
    end
  end

  config.add_on_error(filter_http_post_params)
end
