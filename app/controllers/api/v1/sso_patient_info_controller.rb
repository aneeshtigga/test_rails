module Api
  module V1
    class SsoPatientInfoController < ApplicationController
      skip_before_action :verify_jwt_token

      def index
        if authenticated?
          render json: { patient_info: patient_info }, status: :ok and return
        elsif valid_token?
          store_session_data
          expire_token!
          render json: { patient_info: patient_info }, status: :ok and return
        end

        render json: { message: "Session expired" }, status: :unauthorized and return
      end

      private

      def valid_token?
        token&.active?
      end

      def token
        @token ||= SsoToken.find_by_token(params[:token])
      end

      def expire_token!
        @token.update(expire_at: Time.now)
      end

      def selected_patient_id
        session[:selected_patient_id]
      end

      def authenticated?
        !selected_patient_id.nil?
      end

      def store_session_data
        session[:selected_patient_id] = token.data["selected_patient_id"]
        session[:license_key] = token.data["license_key"]
        session[:responsible_party_id] = token.data["responsible_party_id"]
        session[:authorized_patient_ids] = token.data["authorized_patient_ids"]
      end

      def patient_info
        {
          selected_patient_id: session[:selected_patient_id],
          license_key: session[:license_key],
          responsible_party_id: session[:responsible_party_id],
          authorized_patient_ids: session[:authorized_patient_ids],
          authorized_patients_list: get_patient_details
        }
      end

      def get_patient_details
        if session[:authorized_patient_ids].present?
          session[:authorized_patient_ids].split(";").map do |patient_id|
            client.patients.get_demographics(patient_id).profile_data
          end
        else
          []
        end
      end

      def client
        @client ||= Amd::AmdClient.new(office_code: session[:license_key])
      end

      def current_patient_id
        session[:selected_patient_id]
      end
    end
  end
end
