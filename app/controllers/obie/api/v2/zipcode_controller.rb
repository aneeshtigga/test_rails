module Obie
  module Api
    module V2
      class ZipcodeController < ApplicationController
        def clinician_count
          postal_code = get_zip_code

          if postal_code.present?
            clinician_count = get_clinician_count_by_zip_code(postal_code.state)

            render json: { message: "success", state: postal_code.state, clinician_count: clinician_count},
                   status: :ok and return

          else
            render json: { message: "Enter a valid zip code for United States" }, status: :not_found and return
          end
        end

        def validate_zip
          postal_code = get_zip_code
          feature_enablement = get_feature_enablements(postal_code&.state)

          if postal_code.present? && feature_enablement&.lifestance_state && feature_enablement&.is_obie_active
            zip_codes = []
            zip_codes << postal_code.zip_code
            zip_codes += postal_code&.nearby_zip_codes if postal_code.nearby_zip_codes.present?
            nearby_search = true
            insurances = Insurance.accepted_insurances_by_state(postal_code.state, "obie")
            care_types = care_types_by_app(postal_code.state)

            insurances.push("I don’t see my insurance") if insurances.present?

            render json: { message: "Valid",
                           lifestance_state: feature_enablement&.lifestance_state,
                           enabled_obie: feature_enablement&.is_obie_active,
                           city: postal_code.city,
                           state: postal_code.state,
                           type_of_cares: care_types,
                           insurances: insurances,
                           nearby_search: nearby_search },
                   status: :ok and return
          elsif postal_code.present? && (!feature_enablement&.is_obie_active || !feature_enablement&.lifestance_state)
            render json: { lifestance_state: feature_enablement&.lifestance_state,
                           enabled_obie: feature_enablement&.is_obie_active,
                           state: postal_code&.state,
                           message: "no clinicians found, as state feature flag of this zip_code is disabled" },
                   status: :not_found and return
          else
            render json: { message: "Enter a valid zip code for United States" }, status: :not_found and return
          end
        end

        private

        def permitted_params
          params.require(:address_info).permit!
        end

        def zip_code_param
          permitted_params[:zip_code]
        end

        def get_zip_code
          PostalCode.find_by(zip_code: zip_code_param)
        end

        def get_feature_enablements(state)
          FeatureEnablement.find_by(state: state)
        end

        def get_clinician_count_by_zip_code(state)
          ClinicianAddress.within_state(state).map(&:clinician_id).uniq.count
        end

        def care_types_by_app(state)
          care_types = TypeOfCare.by_state(state)
          care_types = care_types.with_non_follow_up_cares

          care_types.with_non_testing_cares.map(&:type_of_care)
        end
      end
    end
  end
end
