module Amd
  module Data
    class AmdPatient
      attr_reader :patient

      def initialize(patient)
        @patient = patient
      end

      def name
        "#{patient.last_name}, #{patient.first_name}"
      end

      def sex
        patient.gender
      end

      # Convert Patient's gender_identity (GI) into AmdPatient's
      # genderidentity - same variable name but without the "_"
      # AMD expects an integer - the amd_gi_ident
      #
      # This method will return a nil when the @patient.gender_identity is not valid for AMD.
      # Using that nil value allows the params method to drop the "@genderidentity" field from 
      # the payload going to AMD.
      def gender_identity
        GenderIdentity.amd_gi_ident_from_gi(patient.gender_identity)
      end

      def dob
        patient.date_of_birth.to_date.strftime("%m/%d/%Y")
      end

      def relationship
        type = patient.account_holder_relationship.to_sym

        relationship_types[type]
      end

      def hipaarelationship
        type = patient.account_holder_relationship

        hipaa_relationship_codes(type.downcase)
      end

      def chart
        "AUTO"
      end

      def zip
        patient.intake_address&.postal_code
      end

      def city
        patient.intake_address&.city
      end

      def state
        patient.intake_address&.state
      end

      def address1
        patient.intake_address&.address_line2
      end

      def address2
        patient.intake_address&.address_line1
      end

      def otherphone
        patient.phone_number
      end

      def othertype #otherphone type
        "C" # CELL
      end

      def email
        (patient.account_holder_relationship == "self")? patient.account_holder.email : "" 
      end

      def respparty_name
        return "SELF" if patient.account_holder_relationship == "self"

        "resp#{patient.account_holder.amd_respparty_id}"
      end

      def respparty
        return "SELF" if patient.account_holder_relationship == "self"

        "resp#{patient.account_holder.amd_respparty_id}"
      end

      def accttype
        "4" # Standard Type
      end

      def profile
        patient.profile_id
      end

      def id
        patient.amd_patient_id
      end

      def params
        data = {
          "@id" => id,
          "@respparty" => respparty,
          "@name" => name,
          "@sex" => sex,
          "@relationship" => relationship,
          "@hipaarelationship" => hipaarelationship,
          "@dob" => dob,
          "@chart" => chart,
          "@profile" => profile,
          address:
            { "@zip" => zip,
              "@city" => city,
              "@state" => state,
              "@address1" => address1,
              "@address2" => address2 },
          contactinfo:
            { "@otherphone" => otherphone,
              "@othertype" => othertype,
              "@email" => email },
          resppartylist: {
            respparty: {
              "@respparty_name" => respparty_name,
              "@accttype" => accttype
            }
          }
        }

        gi = gender_identity
        # Only add the @genderidentity field if it is valid for AMD
        data["@genderidentity"] = gi unless gi.nil?

        data
      end

      private

      def hipaa_relationship_codes(type)
        type = type.titleize
        hipaa_relationship = HipaaRelationshipCode.find_by(description: type)
        hipaa_relationship&.code
      end

      def relationship_types
        { self: 1, spouse: 2, child: 3, other: 4 }
      end
    end
  end
end
