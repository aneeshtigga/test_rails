module Api
  module V1
    class InsuranceController < ApplicationController
      def index
        return render(json: { insurances: insurances_by_care }, status: :ok) if postal_code.present?
        
        render json: { message: "Enter a valid zip code for United States" }, status: :not_found
      end


      private

      def permitted_params
        params.permit(:zip_code, :type_of_care)
      end

      def zip_code_param
        permitted_params[:zip_code]
      end

      def care_param
        permitted_params[:type_of_care]
      end

      def postal_code
        @postal_code ||= PostalCode.find_by(zip_code: zip_code_param)
      end

      def insurances_by_care
        # debugger
        clinician_addresses = ClinicianAddress.within_state(postal_code.state)
        clinician_addresses = clinician_addresses.with_care(care_param) if care_param.present?
        insurances = clinician_addresses.left_joins(:insurances)
                                        .where(insurances: Insurance.filter_for_app(params[:app_name]))
                                        .order(:name)
                                        .pluck("distinct(insurances.name)").compact

        insurances.present? ? insurances.push("I don’t see my insurance") : ["I don’t see my insurance"]
      end
    end
  end
end
