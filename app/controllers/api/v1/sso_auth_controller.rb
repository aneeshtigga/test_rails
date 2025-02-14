module Api
  module V1
    class SsoAuthController < ApplicationController
      skip_before_action :verify_jwt_token
      protect_from_forgery except: [:index, :destroy]

      def index
        if jwt.blank?
          render json: { message: "Missing required params" }, status: :unprocessable_entity and return
        else
          create_sso_token
          render json: { redirect_url: redirect_url }, status: :ok and return
        end
      rescue Jose::ExpiredSignature
        render json: { message: "Expired token" }, status: :unprocessable_entity and return
      rescue JSON::JWT::InvalidFormat
        render json: { message: "Invalid json format" }, status: :unprocessable_entity and return
      rescue JSON::JWE::DecryptionFailed
        render json: { message: "JWT decryption failed" }, status: :unprocessable_entity and return
      end

      def destroy
        reset_session
        session.delete(:selected_patient_id)
      end

      private

      def create_sso_token
        data = {
          selected_patient_id: decrypted_payload["selectedPatientId"],
          license_key: decrypted_payload["licenseKey"],
          responsible_party_id: decrypted_payload["responsiblePartyId"],
          authorized_patient_ids: decrypted_payload["authorizedPatients"]
        }

        @auth_token = SsoToken.create!(data: data)
      end

      def decrypted_payload
        Jose.decrypt_and_verify(jwt)
      end

      def jwt
        params[:jwt]
      end

      def redirect_url
        "#{Rails.application.credentials.host_url}/find-care/booking/followup?token=#{@auth_token.token}"
      end
    end
  end
end
