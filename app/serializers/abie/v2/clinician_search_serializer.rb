module Abie
  module V2
    class ClinicianSearchSerializer < Abie::ClinicianSearchSerializer
      attributes(:addresses)

      def addresses
        [ActiveModelSerializers::SerializableResource.new(object,
                                                          each_serializer: Abie::V2::ClinicianAddressSerializer,
                                                          postal_code: @instance_options[:postal_code])]
      end
    end
  end
end