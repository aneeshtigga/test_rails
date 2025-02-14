module Amd
  module Api
    class AutoAssignFormsApi < BaseApi
      def auto_assign(params)
        payload = {
          ppmdmsg: {
            '@action': "autoassignforms",
            '@appointmentid': params["id"],
            '@class': "patientforms",
            '@msgtime': msgtime,
            '@patientid': params["patientid"],
            '@types': params["appointmenttypeids"].nil? ? "" : params["appointmenttypeids"][0],
            '@v': "1",
            '@lac': "/api/onlinescheduling/appointments",
            '@la': "POST"
          }
        }.to_json
        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
      end
    end
  end
end
