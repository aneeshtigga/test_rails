module Amd
  module Data
    class PatientDemographics
      attr_reader :data

      def initialize(data)
        @data = OpenStruct.new(data)
      end

      def id
        data["@id"].gsub(/\D/, "").to_i
      end

      def name
        data["@name"]
      end

      def first_name
        name.split(",").last
      end

      def last_name
        name.split(",").first
      end

      def date_of_birth
        data["@dob"]
      end

      def gender
        genders_list = {
          M: "male",
          F: "female",
          U: "other"
        }
        genders_list[data["@sex"].to_sym] || nil
      end

      def profile_data
        {
          id: id,
          name: "#{first_name} #{last_name}",
          date_of_birth: date_of_birth,
          gender: gender,
          location: location
        }
      end

      def patient_information
        {
          id: id,
          first_name: first_name,
          last_name: last_name,
          date_of_birth: date_of_birth,
          gender: gender,
          care_team_members: [],
          care_team_count: 0
        }
      end

      def address
        data["address"]
      end

      def zip_code
        address["@zip"]
      end

      def city
        address["@city"]
      end

      def state
        address["@state"]
      end

      def address1
        address["@address1"]
      end

      def address2
        address["@address2"]
      end

      def location
        loc = ""
        loc += "#{address1},"  if address1.present?
        loc += "#{address2},"  if address2.present?
        loc += "#{city}," if city.present?
        loc += "#{state}," if state.present?
        loc += zip_code.to_s if zip_code.present?
        loc
      end
    end
  end
end
