module Amd
  module Data
    class PatientInsuranceCoverage
      attr_reader :patient, :insurance_coverage, :policy_holder, :policy_holder_address

      def initialize(patient)
        @patient = patient
        @insurance_coverage = @patient.insurance_coverages.last
        @policy_holder = @insurance_coverage.policy_holder
        @policy_holder_address = @policy_holder.intake_address
      end

      def policy_holder_name
        "#{policy_holder.last_name},#{policy_holder.first_name}"
      end

      def policy_holder_gender
        @policy_holder.gender
      end

      def responsible_party_relation
        @insurance_coverage.relation_to_policy_holder
      end

      def relationship
        patient.policy_holder_mapping(responsible_party_relation)[:relationship]
      end

      def hipaarelationship
        patient.policy_holder_mapping(responsible_party_relation)[:hipaarelationship]
      end

      def policy_holder_dob
        begin
          date = Date.strptime(policy_holder.date_of_birth, "%m/%d/%Y").strftime("%m/%d/%Y")
        rescue StandardError => e
          date = policy_holder.date_of_birth.to_date.strftime("%m/%d/%Y")
        end
        date
      end

      def policy_holder_email
        policy_holder.email
      end

      def patients_provider_id
        patient.profile_id
      end

      def chart
        "AUTO"
      end

      def payload
        {
          patient: {
            respparty: policy_holder_name,
            name: policy_holder_name,
            sex: policy_holder_gender,
            relationship: relationship,
            hipaarelationship: hipaarelationship,
            dob: policy_holder_dob,
            chart: chart,
            profile: patients_provider_id,
            address: {
              zip: policy_holder_address.postal_code,
              city: policy_holder_address.city,
              state: policy_holder_address.state,
              address1: policy_holder_address.address_line2, # AMD is reversed for addresses
              address2: policy_holder_address.address_line1
            },
            contactinfo: {
              homephone: "",
              officephone: "",
              officeext: "",
              otherphone: patient.phone_number,
              othertype: "C",
              email: policy_holder_email
            }
          },
          respparty: {
            '@name': policy_holder_name,
            '@accttype': "4",
            '@sex': policy_holder_gender,
            '@dob': policy_holder_dob
          }
        }
      end

      def lookup_payload
        {
          first_name: policy_holder.first_name,
          last_name: policy_holder.last_name,
          date_of_birth: policy_holder_dob,
          email: policy_holder_email,
          gender: policy_holder_gender
        }
      end
    end
  end
end

