module Amd
  module Api
    class ReferralApi < BaseApi
      def lookup_ref_source(name)
        api_action = "lookupmarsource"
        api_class = "api"

        payload = {
          ppmdmsg: {
            '@action': api_action,
            '@class': api_class,
            '@exactmatch': "0",
            '@name': name
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        marketing_source = json_resp.dig("PPMDResults", "Results", "marsourcelist", "marsource")

        Bugsnag.notify("Missing AMD referral source: #{name}") if marketing_source.blank?

        marketing_source["@id"].sub("source", "").to_i if marketing_source.present? && marketing_source["@name"] == name
      end

      def lookup_ref_status(name)
        api_action = "lookupmarstatus"
        api_class = "api"

        payload = {
          ppmdmsg: {
            '@action': api_action,
            '@class': api_class,
            '@exactmatch': "0",
            '@name': name
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        marketing_status = json_resp.dig("PPMDResults", "Results", "marstatuslist", "marstatus")
        marketing_status["@id"].sub("stat", "").to_i if marketing_status.present? && marketing_status["@name"] == name
      end

      def add_patients_referral_source(patient_id, source_id)
        status_id = lookup_ref_status("1-SCHEDULED CONSULT")

        payload = {
          "patientid" => patient_id,
          "sourceid" => source_id,
          "statusid" => status_id
        }.to_json

        resp = send_referral_request(payload, "referral_request", "api")
        json_resp = JSON.parse(resp.body)
        json_resp["id"] if json_resp.present?
      end
    end
  end
end
