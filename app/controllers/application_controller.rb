class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :verify_jwt_token

  def verify_jwt_token
    return if devise_or_active_admin?

    begin
      if jwt_token.present?
        if abie_app?
          # microsoft IDP uses RSA algorithm to encode the jwt. so we have to use the same
          decode_data = JWT.decode(jwt_token, get_rsa_key, false,{ algorithm: 'RS256' })

          render json: {message: "Not a valid JWT token for ABIE"}, status: :unauthorized and return if decode_data.last['alg'] == 'HS256'

          # first element is jwt payload
          token_expiry = decode_data[0]['exp']

          render json: { message: "Jwt token expired at #{Time.at(token_expiry)}" }, status: :unauthorized and return if Time.now > Time.at(token_expiry)

          SsoAudit.find_or_create_by(app_name: decode_data[0]['app_displayname'], first_name: decode_data[0]['given_name'],
                                     last_name: decode_data[0]['family_name'], email: decode_data[0]['unique_name'],
                                     created_at: Date.current)

        else
          decode_data = JsonWebToken.decode(jwt_token)

          unless decode_data.present? && (application_names.include? decode_data[:application_name])
            render json: { message: "Jwt token expired or invalid" }, status: :unauthorized and return
          end
        end
      elsif jwt_token.blank?
        render json: {message: 'Missing JWT'}, status: :unauthorized and return # using unless, as over commit complains
      end
    rescue StandardError => e
      ErrorLogger.report(e)

      render json: { message: "Error in validating JWT", error: e.message },
             status: :unprocessable_entity
    end
  end

  def application_names
    [Rails.application.credentials.ols_api_app_name, Rails.application.credentials.ols_amd_api_app_name]
  end

  protected

  def devise_or_active_admin?
    devise_controller? || active_admin_resource?
  end

  def active_admin_resource?
    self.class.ancestors.include? ActiveAdmin::BaseController
  end

  def jwt_token
    authorization = request.headers["Authorization"]
    authorization.split.last if authorization.present?
  end

  def abie_app?
    app_name = 'ABIE'
    request.path&.upcase&.include? app_name or request.params['app_name']&.upcase == app_name
  end

  def get_rsa_key
    common_keys = RestClient.get('https://login.microsoftonline.com/common/discovery/keys')
    JSON.parse(common_keys)['keys'][0]['n']
  end
end