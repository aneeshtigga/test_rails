module Api
  module V1
    class ZipcodeController < ApplicationController
      def validate_zip
        postal_code = get_zip_code
        if postal_code.present?
          zip_codes = []
          zip_codes << postal_code.zip_code
          zip_codes += postal_code&.nearby_zip_codes if postal_code.nearby_zip_codes.present?
          nearby_search = true
          insurances = Insurance.accepted_insurances_by_state(postal_code.state, app_name)
          care_types = care_types_by_app(postal_code.state)

          insurances.push("I don’t see my insurance") if insurances.present?

          render(
            json: { 
              message: "Valid", city: postal_code.city, state: postal_code.state, 
              type_of_cares: care_types, insurances: insurances, nearby_search: nearby_search
             },
             status: :ok
          )
        else
          render json: { message: "Enter a valid zip code for United States" }, status: :not_found and return
        end
      end

      private

      def care_types_by_app(state)
        care_types = TypeOfCare.by_state(state)
        care_types = care_types.with_non_follow_up_cares

        if abie?
          care_types.map(&:type_of_care)
        else
          care_types.with_non_testing_cares.map(&:type_of_care)
        end

        
      end

      def permitted_params
        params.require(:address_info).permit!
      end

      def zip_code_param
        permitted_params[:zip_code]
      end

      def get_zip_code
        PostalCode.find_by(zip_code: zip_code_param)
      end

      def app_name
        params[:app_name]&.downcase || "obie"
      end

      def abie?
        app_name == "abie"
      end
    end
  end
end
