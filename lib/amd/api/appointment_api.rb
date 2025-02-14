module Amd
  module Api
    class AppointmentApi < BaseApi
      def lookup_appointment(params)
        params = {
          id: params[:id],
          clientDateTime: params[:client_date_time],
          getEecurException: params[:get_recur_exception],
          includeDetail: params[:include_detail]
        }

        resp = get_request(params)

        json_resp = JSON.parse(resp.body)

        return {} if json_resp["id"].blank?

        json_resp
      rescue StandardError => e
        ErrorLogger.report(e)
        {}
      end

      def add_appointment(params)
        payload = params.to_json

        resp = send_appointment_request(payload, "add_appointment", "api")
        JSON.parse(resp.body)
      rescue StandardError => e
        ErrorLogger.report(e) unless e.message == "409 Conflict"
        {}
      end

      def cancel_appointment(update_params)
        payload = update_params

        resp = send_referrel_headers_update_request(payload, "cancel")

        json_resp = JSON.parse(resp.body) if resp.body.present?

        json_resp if json_resp.present? && json_resp["id"].present?
      rescue StandardError => e
        ErrorLogger.report(e)
        {}
      end
    end
  end
end
