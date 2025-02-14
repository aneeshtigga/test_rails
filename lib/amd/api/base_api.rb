module Amd
  module Api
    class BaseApi
      attr_accessor :config
      attr_reader :base_url, :token

      def initialize(config, base_url, token)
        @config = config
        @base_url = base_url
        @token = token
      end

      def send_request(payload, api_action = "", api_class = "")
        # RestClient.log = 'stdout' # uncomment this line to see the request headers and body in the console
        endpoint = config.request_endpoint
        url = "#{base_url}/#{endpoint}"
        payload_parsed = get_parsed_payload(payload)

        resp = RestClient.post(url, payload.to_s, default_headers)

        ApiLogWorker.perform_async({ payload: payload, response: resp.body, headers: default_headers.to_json, url: url,
                                     time: Time.zone.now, api_action: (api_action.presence || payload_parsed["@action"]), api_class: (api_class.presence || payload_parsed["@class"]), response_code: resp.code, response_message: resp.net_http_res.message, api_method_call: "post" })
        resp
      rescue StandardError => e
        ApiLogWorker.perform_async({ payload: payload, response: { error: e.message }, headers: default_headers.to_json,
                                     url: url, time: Time.zone.now, api_action: (api_action.presence || payload_parsed["@action"]), api_class: (api_class.presence || payload_parsed["@class"]), response_code: 500, response_message: "Error Occured", api_method_call: "post" })
        ErrorLogger.report(e) if e.message != "409 Conflict"
        raise e.message
      end

      def send_appointment_request(payload, api_action = "", api_class = "")
        actual_headers = bearer_token_request_headers
        endpoint = config.request_endpoint
        url = "#{base_url}/#{endpoint}"
        payload_parsed = get_parsed_payload(payload)
        resp = RestClient.post(url, payload, actual_headers)
        ApiLogWorker.perform_async({ payload: payload, response: resp.body, headers: actual_headers.to_json, url: url,
                                     time: Time.zone.now, api_action: (api_action.presence || payload_parsed["@action"]), api_class: (api_class.presence || payload_parsed["@class"]), response_code: resp.code, response_message: resp.net_http_res.message, api_method_call: "post" })
        resp
      rescue StandardError => e
        ApiLogWorker.perform_async({ payload: payload, response: { error: e.message }, headers: actual_headers.to_json,
                                     url: url, time: Time.zone.now, api_action: (api_action.presence || payload_parsed["@action"]), api_class: (api_class.presence || payload_parsed["@class"]), response_code: 500, response_message: "Error Occured", api_method_call: "post" })
        ErrorLogger.report(e) if e.message != "409 Conflict"
        raise e.message
      end

      def send_update_request(payload, action)
        request_url = config.scheduler_request_url.gsub("{api_version}", "#{amd_api_version}")
        member_id = payload["id"]
        url = "#{request_url}/#{member_id}/#{action}"
        payload_parsed = get_parsed_payload(payload)
        resp = RestClient.put(url, payload.to_json, default_headers)
        ApiLogWorker.perform_async({ payload: payload.to_json, response: resp.body, headers: default_headers.to_json,
                                     url: url, time: Time.zone.now, api_action: (action == "cancel" ? "cancel_appointment" : payload_parsed["@action"]), api_class: (payload_parsed["@class"].presence || "api"), response_code: resp.code, response_message: resp.net_http_res.message, api_method_call: "put" })
        resp
      rescue StandardError => e
        ApiLogWorker.perform_async({ payload: payload, response: { error: e.message }, headers: default_headers.to_json,
                                     url: url, time: Time.zone.now, api_action: (action == "cancel" ? "cancel_appointment" : payload_parsed["@action"]), api_class: (payload_parsed["@class"].presence || "api"), response_code: 500, response_message: "Error Occured", api_method_call: "put" })
        ErrorLogger.report(e)
        raise e.message
      end

      def send_referrel_headers_update_request(payload, action)
        actual_headers = bearer_token_request_headers
        request_url = config.scheduler_request_url.gsub("{api_version}", "#{amd_api_version}")
        member_id = payload["id"]
        url = "#{request_url}/#{member_id}/#{action}"
        payload_parsed = get_parsed_payload(payload)
        resp = RestClient.put(url, payload.to_json, actual_headers)
        ApiLogWorker.perform_async({ payload: payload.to_json, response: resp.body, headers: actual_headers.to_json,
                                     url: url, time: Time.zone.now, api_action: (action == "cancel" ? "cancel_appointment" : payload_parsed["@action"]), api_class: (payload_parsed["@class"].presence || "api"), response_code: resp.code, response_message: resp.net_http_res.message, api_method_call: "put" })
        resp
      rescue StandardError => e
        ApiLogWorker.perform_async({ payload: payload, response: { error: e.message }, headers: actual_headers.to_json,
                                     url: url, time: Time.zone.now, api_action: (action == "cancel" ? "cancel_appointment" : payload_parsed["@action"]), api_class: (payload_parsed["@class"].presence || "api"), response_code: 500, response_message: "Error Occured", api_method_call: "put" })
        ErrorLogger.report(e)
        raise e.message
      end      

      def send_referral_request(payload, api_action = "", api_class = "")
        request_url = config.referral_request_url
        endpoint = config.referral_endpoint
        app_name = config.app_name
        url = "#{request_url}/#{app_name}/#{endpoint}"
        resp = RestClient.post(url, payload, bearer_token_request_headers)
        ApiLogWorker.perform_async({ payload: payload, response: resp.body, headers: bearer_token_request_headers.to_json,
                                     url: url, time: Time.zone.now, api_action: api_action, api_class: api_class, response_code: resp.code, response_message: resp.net_http_res.message, api_method_call: "post" })
        resp
      end

      def send_ehr_post_request(payload, api_action = "", api_class = "")
        request_url = config.ehr_file_upload_url
        resp = RestClient.post(request_url, payload, ehr_upload_headers)
        ApiLogWorker.perform_async({ payload: payload, response: resp.body, headers: ehr_upload_headers.to_json,
                                     url: request_url, time: Time.zone.now, api_action: api_action, api_class: api_class, response_code: resp.code, response_message: resp.net_http_res.message, api_method_call: "post" })
        resp
      rescue StandardError => e
        ApiLogWorker.perform_async({ payload: payload, response: { error: e.message },
                                     headers: ehr_upload_headers.to_json, url: request_url, time: Time.zone.now, api_action: api_action, api_class: api_class, response_code: 500, response_message: "Error Occured", api_method_call: "post" })
        ErrorLogger.report(e)
        raise e.message
      end

      private

      def msgtime
        Time.zone.now.strftime("%-m/%-d/%Y %I:%M:%S %p") # required format  4/1/2021 2:16:55 PM,
      end

      def get_request(params)
        url = "#{base_url}/#{params[:id]}"

        RestClient.get(url, default_headers.merge({ params: params }))
      end

      def default_headers
        {
          accept: :json,
          content_type: "application/json",
          cookies: { token: token }
        }
      end

      def bearer_token_request_headers
        {
          accept: :json,
          content_type: "application/json",
          authorization: "Bearer #{token}"
        }
      end

      def get_parsed_payload(payload)
        (JSON.parse(payload)["ppmdmsg"].presence || {})
      rescue StandardError
        {}
      end

      def ehr_upload_headers
        {
          accept: :json,
          content_type: "application/json",
          authorization: "Bearer #{token}",
          appname: config.app_name
        }
      end

      def amd_api_version
        session = AmdApiSession.last
        redirect_url = session.redirect_url
        api_version = redirect_url.split("/")[-2]
      end
    end
  end
end
