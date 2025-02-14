module Amd
  module Api
    class GetEpisodesApi < BaseApi
      def episode_id(id)
        payload = {
          ppmdmsg: {
            '@action': "getepisodes",
            '@class': "demographics",
            '@msgtime': msgtime,
            '@patientid': id
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        episode = json_resp.dig("PPMDResults", "Results", "patientlist", "patient", "episodelist", "episode")

        return if episode.nil?

        id = episode["@id"]

        id.gsub(/\D/, "").to_i
      end
    end
  end
end
