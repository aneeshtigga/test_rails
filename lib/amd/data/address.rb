module Amd
  module Data
    class Address
      attr_reader :data

      def initialize(data)
        @data = OpenStruct.new(data)
      end

      def zip_code
        data["@zip"].split("-").first
      end
    end
  end
end