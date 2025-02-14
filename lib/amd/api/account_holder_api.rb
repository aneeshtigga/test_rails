module Amd
  module Api
    class AccountHolderApi < BaseApi
      def save_account(params)
        payload = {
          ppmdmsg: {
            '@action': "saveaccount",
            '@class': "api",
            '@msgtime': msgtime,
            '@nocookie': 0,
            patientportalaccount: {
              '@emailaddress': params[:email],
              '@fullname': params[:full_name],
              '@comment': "",
              '@disable': "0",
              '@display': "1"
            }
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        if json_resp["PPMDResults"].dig("Results", "patientportalaccount").present?
          json_resp["PPMDResults"]["Results"]["patientportalaccount"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def lookup_account_holder(params)
        payload = {
          ppmdmsg: {
            '@action': "lookuppatientportalaccount",
            '@class': "api",
            '@msgtime': msgtime,
            '@exactmatch': 0,
            '@fullname': params[:full_name],
            '@emailaddress': params[:email]
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        if json_resp["PPMDResults"].dig("Results", "patientportalaccountlist").present?
          json_resp["PPMDResults"]["Results"]["patientportalaccountlist"]["patientportalaccount"]
        else
          {}
        end
      end
    end
  end
end