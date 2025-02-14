module Amd
  module Api
    class CustomDataApi < BaseApi
      def save_patients_data(params)
        payload = {
          ppmdmsg: {
            '@action': "insertcustomdata",
            '@class': "providerdesktop",
            '@patientid': params[:patient_id],
            '@templateid': params[:template_id],
            fieldvaluelist: {
              fieldvalue: params[:field_value_list]
            }
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
        if json_resp["PPMDResults"].dig("Results", "patientlist").present?
          if params[:custom_tab] == 'Emergency Contact'
            update_patient_emergency_contact(params[:patient_id], json_resp)
          elsif params[:custom_tab] == 'Pronouns'
            Patient.find_by(amd_patient_id: params[:patient_id]).update!(amd_pronouns_updated: true)
          end

          json_resp["PPMDResults"]["Results"]["patientlist"]
        else
            json_resp["PPMDResults"]["Error"]
        end
      end

      def update_patients_data(params)
        payload = {
          ppmdmsg: {
            '@action': "updatecustomdata",
            '@class': "providerdesktop",
            '@patientid': params[:patient_id],
            '@templateid': params[:template_id],
            '@instanceid': params[:instance_id],
            fieldvaluelist: {
              fieldvalue: params[:field_value_list]
            }
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
        if json_resp["PPMDResults"].dig("Results", "patientlist").present?
          json_resp["PPMDResults"]["Results"]["patientlist"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def lookup_custom_template(code)
        template = custom_templates.detect { |record| record["@code"] == code }
        if template.present?
          field_list = template["fieldlist"]["field"].map do |field|
            { template_id: template["@uid"], id: field["@id"], name: field["@name"] }
          end
        end
      end

      def custom_templates
        payload = {
          ppmdmsg: {
            '@action': "selectuserfiletemplates",
            '@class': "masterfiles",
            '@templatetype': "pt",
            '@nocookie': "0"
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
        if json_resp["PPMDResults"].dig("Results", "record").present?
          json_resp["PPMDResults"]["Results"]["record"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def update_patient_emergency_contact(amd_patient_id, json_resp)
        patient = Patient.find_by(amd_patient_id: amd_patient_id)

        field_value_list = json_resp["PPMDResults"]["Results"]["patientlist"]["patient"]["templatelist"]["template"]["instancelist"]["instance"]["fieldvaluelist"]["fieldvalue"]
        field_value_list.each do |each_field|
          case each_field["@ordinal"]
          when "1"
            patient.emergency_contact.amd_contact_id = each_field["@id"]
            patient.emergency_contact.amd_instance_id = json_resp["PPMDResults"]["Results"]["patientlist"]["patient"]["templatelist"]["template"]["instancelist"]["instance"]["@id"]
          when "2"
            patient.emergency_contact.amd_relationship_to_patient_id = each_field["@id"]
          when "3"
            patient.emergency_contact.amd_phone_id = each_field["@id"]
          end
        end

        patient.emergency_contact.save!
      end
    end
  end
end
