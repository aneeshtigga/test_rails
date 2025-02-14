class JsonWebToken
  class << self
    def encode(payload)
      if payload[:application_name] == ols_app_name
        payload[:exp] = jwt_expiration_time.minutes.from_now.to_i
      else
        payload[:exp] = amd_jwt_expiration_time.minutes.from_now.to_i
      end
      JWT.encode(payload, secret_key)
    rescue StandardError => e
      ErrorLogger.report(e)
      Rails.logger.error e.message
      nil
    end

    def decode(token)
      body = JWT.decode(token, secret_key)[0]
      HashWithIndifferentAccess.new body
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    rescue StandardError => e
      ErrorLogger.report(e)
      Rails.logger.error e.message
      nil
    end

    private

    def secret_key
      Rails.application.credentials.secret_key_base
    end

    def jwt_expiration_time
      Rails.application.credentials.jwt_expiration_time
    end

    def amd_jwt_expiration_time
      Rails.application.credentials.amd_jwt_expiration_time
    end

    def ols_app_name
      Rails.application.credentials.ols_api_app_name
    end
  end
end
