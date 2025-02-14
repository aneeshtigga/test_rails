module Amd
  module Data
    class PatientInsurances
      attr_reader :patient_data, :insurance_data, :data

      def initialize(data)
        @data = data
        @patient_data = OpenStruct.new(data["patientlist"]["patient"])
      end

      def insurance_details
        patient_data["insplanlist"]["insplan"].map do |insplan|
          @insurance_data = @carrier_data = @policy_holder_data = nil
          @insurance_data = OpenStruct.new(insplan)
          carrier_insurance_info
        end
      end

      def insurances
        if patient_data["insplanlist"].present? && patient_data["insplanlist"]["insplan"].is_a?(Hash)
          @insurance_data = OpenStruct.new(patient_data["insplanlist"]["insplan"])
          [carrier_insurance_info]
        elsif patient_data["insplanlist"].present? && patient_data["insplanlist"]["insplan"].is_a?(Array)
          insurance_details
        end
      end

      def carrier_insurance_info
        {
          amd_insurance_id: amd_insurance_id,
          insurance_carrier: insurance_carrier,
          member_id: member_id,
          mental_health_phone_number: mental_health_phone_number,
          primary_policy_holder: primary_policy_holder,
          policy_holder: policy_holder
        }
      end

      def amd_insurance_id
        insurance_data["@id"]
      end

      def carrier_data
        if data["carrierlist"].present? && data["carrierlist"]["carrier"].is_a?(Hash)
          carrier = data["carrierlist"]["carrier"]
          @carrier_data ||= OpenStruct.new(carrier)
        elsif data["carrierlist"].present? && data["carrierlist"]["carrier"].is_a?(Array)
          carrier = data["carrierlist"]["carrier"].detect{|carrier| carrier["@id"] == insurance_carrier_id }
          @carrier_data ||= OpenStruct.new(carrier)
        end
      end

      def policy_holder_data
        policy_holder = if data["resppartylist"]["respparty"].is_a?(Hash)
                          data["resppartylist"]["respparty"]
                        else
                          data["resppartylist"]["respparty"].detect { |respparty| respparty["@id"] == subscriber }
                        end
        @policy_holder_data ||= OpenStruct.new(policy_holder)
      end

      def patient_id
        patient_data["@id"].gsub(/\D/, "").to_i
      end

      def patient_full_name
        patient_data["@name"]
      end

      def response
        {
          patient_id: patient_id,
          patient_name: patient_full_name,
          insurance_details: insurances
        }
      end

      def subscriber
        insurance_data["@subscriber"]
      end

      def insurance_carrier
        carrier_data["@name"].delete("X")
      end

      def insurance_carrier_id
        insurance_data["@carrier"]
      end

      def member_id
        insurance_data["@subscribernum"]
      end

      def mental_health_phone_number
        ""
      end

      def primary_policy_holder
        HipaaRelationshipCode.find_by(code: insurance_data["@hipaarelationship"]).description
      end

      def hippa_self_code
        HipaaRelationshipCode.find_by(description: "Self").code
      end

      def policy_holder
        if insurance_data["@hipaarelationship"] == hippa_self_code
          ""
        else
          {
            first_name: policy_holder_first_name,
            last_name: policy_holder_last_name,
            date_of_birth: policy_holder_dob,
            gender: policy_holder_gender,
            email: policy_holder_email
          }
        end
      end

      def policy_holder_first_name
        policy_holder_data["@name"].split(",", 2).last
      end

      def policy_holder_last_name
        policy_holder_data["@name"].split(",", 2).first
      end

      def policy_holder_dob
        policy_holder_data["@dob"]
      end

      def policy_holder_gender
        case policy_holder_data["@sex"]
        when "M"
          "Male"
        when "F"
          "Female"
        else
          "Others"
        end
      end

      def policy_holder_email
        policy_holder_data["@email"]
      end
    end
  end
end
