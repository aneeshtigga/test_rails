module Amd
  module Api
    class ResponsiblePartyApi < BaseApi
      GENDER = {
        male: "m",
        female: "f",
        other: "o",
        m: "m",
        f: "f",
        u: "u"
      }

      def lookup_responsible_party(params)
        first_name = params[:first_name]
        last_name = params[:last_name]
        date_of_birth = params[:date_of_birth]
        responsible_parties = lookup_responsible_party_by_name(first_name, last_name)

        filtered_parties = responsible_parties.select do |responsible_party|
          responsible_party.first_name.to_s.downcase == first_name.to_s.downcase &&
            responsible_party.last_name.to_s.downcase == last_name.to_s.downcase &&
            responsible_party.date_of_birth.to_s == date_of_birth.to_s
        end
        filtered_parties.first
      end

      def add_responsible_party(params)
        payload = build_payload(params)

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
        if json_resp["PPMDResults"]["Results"]["@success"] == "1"
          json_resp["PPMDResults"]["Results"]["respparty"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def build_payload(params)
        payload = {
          ppmdmsg: {
            '@action': "addrespparty",
            '@class': "demographics",
            '@msgtime': msgtime,
            'patientlist': {},
            'resppartylist': {},
          }
        }

        if params[:respparty].present?
          payload[:ppmdmsg][:resppartylist][:respparty] = params[:respparty]
        end

        if params[:patient].present?
          payload[:ppmdmsg][:patientlist][:patient] = patient_attributes(params[:patient])
        end

        if params[:patientid].present?
          payload[:ppmdmsg]["@patientid"] = params[:patientid]
        end

        payload.to_json
      end

      def get_responsible_party(id)
        payload = {
          ppmdmsg: {
            '@action': "getrespparty",
            '@class': "demographics",
            '@msgtime': msgtime,
            '@resppartyid': id,
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        if json_resp["PPMDResults"]["Results"].present?
          json_resp["PPMDResults"]["Results"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def get_responsible_party_self(id) 
        payload = {
          ppmdmsg: {
            '@action': "getresponsiblepartyself",
            '@class': "api",
            '@msgtime': msgtime,
            '@responsiblepartyid': id,
            '@la': "getfamilymembers",
         } 

        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        if json_resp["PPMDResults"]["Results"].present?
          json_resp["PPMDResults"]["Results"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      private

      def lookup_responsible_party_by_name(first_name, last_name, exact_match = "1")
        api_action = "lookuprespparty"
        api_class = "api"
        name = "#{last_name},#{first_name}"

        payload = {
          ppmdmsg: {
            '@action': api_action,
            '@class': api_class,
            '@exactmatch': exact_match,
            '@name': name,
            '@page': "1",
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
        results = json_resp["PPMDResults"]["Results"]
        if results.present? && results["respparty"].present?
          records = [results["respparty"]].flatten
          responsible_parties = records.map do |responsible_party|
            Amd::Data::ResponsibleParty.new(responsible_party)
          end
        elsif  results.present? && results["resppartylist"]["respparty"].present?
          records = [results["resppartylist"]["respparty"]].flatten
          responsible_parties = records.map do |responsible_party|
            Amd::Data::ResponsibleParty.new(responsible_party)
          end
        else
          []
        end
      end

      def patient_attributes(params)
        {
          '@respparty': params[:respparty],
          '@name': params[:name],
          '@sex': params[:sex],
          '@relationship': params[:relationship],
          '@hipaarelationship': params[:hipaarelationship],
          '@dob': params[:dob],
          '@ssn': params[:ssn],
          '@chart': params[:chart],
          '@profile': params[:profile],
          '@finclass': params[:finclass],
          '@deceased': params[:deceased],
          '@title': params[:title],
          '@maritalstatus': params[:maritalstatus],
          '@insorder': params[:insorder],
          '@employer': params[:employer],
          address: {
            '@zip': params[:address][:zip],
            '@city': params[:address][:city],
            '@state': params[:address][:state],
            '@address1': params[:address][:address1],
            '@address2': params[:address][:address2],
          },
          contactinfo: {
            '@homephone': params[:contactinfo][:homephone],
            '@officephone': params[:contactinfo][:officephone],
            '@officeext': params[:contactinfo][:officeext],
            '@otherphone': params[:contactinfo][:otherphone],
            '@othertype': params[:contactinfo][:othertype],
            '@email': params[:contactinfo][:email]
          }
        }
      end
    end
  end
end