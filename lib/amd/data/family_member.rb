module Amd
  module Data
    class FamilyMember
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

      def chart
        data["@chart"]
      end

      def zip_code
        address.zip_code
      end

      def chart
        data["@chart"]
      end

      def responsible_party?
        data["@isrp"] == "1"
      end

      def address
        Amd::Data::Address.new(data["address"])
      end
    end
  end
end