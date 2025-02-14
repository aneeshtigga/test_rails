# spec/support/mocks_and_stubs/amd_api_baseapi_stub.rb

# We are stubbing out the send_request method so that it
# returns a specific known response body whose value is
# a JSON string.  Each spec example that makes use of
# some kind of AMD API call must know what to expect
# as the response to its request.  That known response
# be be set as a "given" value in the spec example
# using the fake_response= method.
#
# Each spec example must ensure the the faile_response
# value is set back to NIL so that it does not cause
# pollution of the known values for other examples.

require_relative 'fake_response_mock'

module Amd
  module Api
    class BaseApi

      FIXTURE_DIR = "#{Rails.root}/spec/fixtures".freeze


      # This is a FakeResponse object whose body valie is a
      # JSON string provided by the soec example
      #
      attr_reader :fake_response

      # Saving the address of the original send_request method
      # so that the stub can be bypassed during the development
      # process where the VCR functionality is being removed.
      #
      alias original_send_request send_request


      def load_fake_response_from(fixture_filename)
        fixture_path = if fixture_filename.end_with? ".json"
          File.new "#{FIXTURE_DIR}/#{fixture_filename}"
                       else
          File.new "#{FIXTURE_DIR}/#{fixture_filename}.json"
                       end 

        raise "FileDoesNotExist #{fixture_filename}" unless File.exist?(fixture_path)

      
        @fake_response      = FakeResponse.new
        @fake_response.body = fixture_path.read
        @fake_response
      end

      def send_request(payload, api_action = "", api_class = "")
        if @fake_response&.body.nil? 
          # Doing this because not all VCR junk is changed at the same time
          original_send_request(payload, api_action, api_class)
        else
          fake_response
        end
      end

      def send_referral_request(payload, api_action = "", api_class = "")
        if @fake_response&.body.nil? 
          # Doing this because not all VCR junk is changed at the same time
          original_send_request(payload, api_action, api_class)
        else
          fake_response
        end
      end
    end
  end
end
