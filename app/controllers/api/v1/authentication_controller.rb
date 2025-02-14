module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :verify_jwt_token

      def generate_token
        if valid_application_name?
          jwt_token = get_jwt_token
          render json: { message: "Jwt token", jwt_token: jwt_token }, status: :ok and return
        else
          render json: { message: "Invalid request" }, status: :bad_request and return
        end
      end

      def valid_application_name?
        params[:application_name].present? && (application_names.include? params[:application_name])
      end

      def get_jwt_token
        JsonWebToken.encode({ application_name: params[:application_name] })
      end
    end
  end
end
