module Amd
  module Api
    class InsuranceApi < BaseApi
      def add_insurance(params)
        payload = {
          ppmdmsg: {
            '@action': "addinsurance",
            '@class': "demographics",
            '@msgtime': msgtime,
            '@ltq': Time.zone.now,
            '@lst': Time.zone.now,
            patient: {
              '@id': "pat#{params[:patient_id]}",
              '@changed': params[:changed].presence || 1,
              'insplanlist': {
                'insplan': insurance_plan_attributes(params[:insurance_plan])
              }
            }
          }
        }.to_json

        resp = send_request(payload)

        json_resp = JSON.parse(resp.body)

        if json_resp["PPMDResults"]["Results"].present? && json_resp["PPMDResults"]["Results"]["@success"] == "1"
          json_resp["PPMDResults"]["Results"]["patient"]
        else
          json_resp["PPMDResults"]["Error"]
        end

      end

      def insurance_plan_attributes(params)
        {
          '@id': params[:id],
          '@begindate': (params[:begindate].presence || Time.zone.now.beginning_of_month.strftime("%-m/%-d/%Y")),
          '@enddate': params[:enddate],
          '@carrier': params[:carrier],
          '@subscriber': "resp#{params[:subscriber]}",
          '@subscribernum': params[:subscribernum],
          '@hipaarelationship': params[:hipaarelationship].to_s,
          '@relationship': params[:relationship].to_s,
          '@grpname': params[:grpname],
          '@grpnum': params[:grpnum],
          '@copay': params[:copay],
          '@copaytype': params[:copaytype],
          '@coverage': params[:coverage],
          '@payerid': params[:payerid],
          '@mspcode': params[:mspcode],
          '@eligibilityid': params[:eligibilityid],
          '@eligibilitystatusid': params[:eligibilitystatusid],
          '@eligibilitychangedat': params[:eligibilitychangedat],
          '@eligibilitycreatedat': params[:eligibilitycreatedat],
          '@eligibilityresponsedate': params[:eligibilityresponsedate],
          '@finclasscode': params[:finclasscode],
          '@deductible': params[:deductible],
          '@deductiblemet': params[:deductiblemet],
          '@yearendmonth': params[:yearendmonth],
          '@lifetime': params[:lifetime],
          'insnote': {
              '@self-closing': params[:self_closing] || "true"
          }
        }
      end
    end
  end
end
