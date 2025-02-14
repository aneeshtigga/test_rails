module Amd
  module Data
    class Patient
      attr_reader :data

      def initialize(data)
        @data = OpenStruct.new(data)
      end

      def id
        data["@id"]
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
        data["@gender"]
      end

      def email
        data["@email"]
      end

      def zip_code
        address.zip_code
      end

      def address
        Amd::Data::Address.new(data["address"])
      end
    end
  end
end