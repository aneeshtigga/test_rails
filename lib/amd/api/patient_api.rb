module Amd
  module Api
    class PatientApi < BaseApi
      GENDER = {
        male: "m",
        female: "f",
        other: "o"
      }

      def lookup_patient(params)
        first_name = params[:first_name]
        last_name = params[:last_name]
        date_of_birth = params[:date_of_birth]
        email = params[:email]
        gender = params[:gender]
        patients = lookup_patient_by_name(first_name, last_name)

        filtered_patients = patients.select do |patient|
          patient.first_name.to_s.downcase == first_name.to_s.downcase &&
            patient.last_name.to_s.downcase == last_name.to_s.downcase &&
            patient.date_of_birth.to_s == date_of_birth.to_s &&
            patient.email.to_s.downcase == email.to_s.downcase &&
            patient.gender.to_s.downcase == GENDER[gender.to_s.downcase.to_sym].to_s
        end

        filtered_patients.first
      end

      def add_patient(params)
        resp_party_id = params["@respparty"]

        unless params["@respparty"].start_with?("resp") then
          resp_party_id = lookup_responsible_party_value(params)
        end
        
        payload = {
          ppmdmsg: {
            '@action': "addpatient",
            '@class': "api",
            '@msgtime': msgtime,
            '@nocookie': 0,
            patientlist: {
              patient: params
            },
            resppartylist: {
              respparty: {
                '@name': params[:resppartylist][:respparty]["@respparty_name"],
                '@accttype': params[:resppartylist][:respparty]["@accttype"]
              }
            }
          }
        }

        payload[:ppmdmsg][:patientlist][:patient][:resppartylist][:respparty]["@respparty_name"] = resp_party_id
        payload[:ppmdmsg][:patientlist][:patient]["@respparty"] = resp_party_id
        payload[:ppmdmsg][:resppartylist][:respparty]["@name"] = resp_party_id

        resp = send_request(payload.to_json)
        json_resp = JSON.parse(resp.body)

        if json_resp["PPMDResults"].dig("Results", "@success") == "1"
          json_resp["PPMDResults"]["Results"]["patientlist"]["patient"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def lookup_responsible_party_value(params)
        #First we do a lookup to check if the patient exist as a responsible party on AMD
        api_action = "lookuprespparty"
        api_class = "api"
        name = params["@name"].strip.upcase.gsub(/,\s+/, ',') #AMD NAME FORMAT IS "UPPERCASELASTNAME,UPPERCASEFIRSTNAME"
        
        payload = {
          ppmdmsg: {
            '@action': api_action,
            '@class': api_class,
            '@exactmatch': "1",
            '@name': name,
            '@page': "1",
          }
        }.to_json
        
        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        value = "SELF" # By default is SELF but if it exists on AMD as a responsible party we need to get the ID

        #If we get results we look for the responsible party who has the same DOB of the patient we are trying to create
        if json_resp.dig("PPMDResults", "Results", "resppartylist", "@itemcount") then
          if json_resp.dig("PPMDResults", "Results", "resppartylist", "@itemcount").to_i > 0 then
            results = json_resp["PPMDResults"]["Results"]["resppartylist"]["respparty"]
            if results.is_a?(Hash) then #If we get 1 result AMD returns an object
              if params["@dob"] == results["@dob"] && name == results["@name"] then
                value = results["@id"]
              end
            elsif results.is_a?(Array) then #Otherwise we get an array of objects
              results.each do | party |
                if params["@dob"] == party["@dob"] && name == party["@name"] then
                  value = party["@id"]
                end
              end
            end
          end
        end

        value
      end

      def update_patient(params)
        payload = {
          ppmdmsg: {
            '@action': "updatepatient",
            '@class': "api",
            '@msgtime': msgtime,
            '@force': "1",
            '@nocookie': 0,
            patientlist: {
              patient: params
            }
          }
        }.to_json

        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)

        if json_resp["PPMDResults"]["Results"].present? && json_resp["PPMDResults"]["Results"]["patientlist"].present?
          json_resp["PPMDResults"]["Results"]["patientlist"]["patient"]
        else
          json_resp["PPMDResults"]["Error"]
        end
      end


      def get_demographics(patient_id)
        payload = {
          'ppmdmsg': {
            '@action': "getdemographic",
            '@class': "api",
            '@msgtime': msgtime,
            '@patientid': patient_id
          }
        }.to_json
        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
        if json_resp["PPMDResults"]["Results"].present? && json_resp["PPMDResults"]["Results"]["patientlist"]["patient"].present?
          patient = json_resp["PPMDResults"]["Results"]["patientlist"]["patient"]
          Amd::Data::PatientDemographics.new(patient)
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def get_patient_insurance(patient_id)
        payload = {
          'ppmdmsg': {
            '@action': "getdemographic",
            '@class': "demographics",
            '@msgtime': msgtime,
            '@patientid': patient_id
          }
        }.to_json
        resp = send_request(payload)
        json_resp = JSON.parse(resp.body)
        if json_resp["PPMDResults"]["Results"].present? 
          patient_details = json_resp["PPMDResults"]["Results"]
          Amd::Data::PatientInsurances.new(patient_details)
        else
          json_resp["PPMDResults"]["Error"]
        end
      end

      def lookup_patient_by_name(first_name, last_name, exact_match = "-1")
        api_action = "lookuppatient"
        api_class = "api"
        name = "#{last_name},#{first_name}".strip.upcase.gsub(/,\s+/, ',')

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


        if json_resp["PPMDResults"]["Results"].present? && json_resp["PPMDResults"]["Results"]["patientlist"]["patient"].present?
          records = [json_resp["PPMDResults"]["Results"]["patientlist"]["patient"]].flatten
          patients = records.map do |patient_data|
            Amd::Data::Patient.new(patient_data)
          end
          patients
        else
          []
        end
      end
    end
  end
end