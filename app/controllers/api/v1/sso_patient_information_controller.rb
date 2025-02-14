module Api
  module V1
    class SsoPatientInformationController < ApplicationController
      skip_before_action :verify_jwt_token

      def index
        if authenticated?
          render json: { patient_information: get_patient_info }, status: :ok and return
        else
          render json: { message: "Session expired" }, status: :unauthorized and return
        end
      end

      private

      def selected_patient_id
        session[:selected_patient_id]
      end

      def authenticated?
        !selected_patient_id.nil?
      end

      def get_patient_info
        patient_information_data = client.patients.get_demographics(selected_patient_id).patient_information
        patient_information_data.merge(authorized_patient_list: get_authorized_patient_details)
        patient_information_data
      end

      def get_authorized_patient_details
        if session[:authorized_patient_ids].present?
          session[:authorized_patient_ids].split(";").map do |patient_id|
            get_patient_information(patient_id)
          end
        else
          []
        end
      end

      def client
        @client ||= Amd::AmdClient.new(office_code: session[:license_key])
      end

      def get_patient_information(patient_id)
        client.patients.get_demographics(patient_id).patient_information
      end
    end
  end
end
