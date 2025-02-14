module Api
  module V1
    class FilterDataController < ApplicationController
      def index
        # We retrieve all the information needed to fill the dropdowns and checkboxes required by UX
        locations = FacilityFilters.get_locations(filter_params)
        special_case = SpecialCase.with_age_types(params[:patient_type])
        concerns = Concern.with_age_types(params[:patient_type]).order(:name)
        expertise = Expertise.all.order(:name)
        interventions = Intervention.all.order(:name)
        populations = Population.all.order(:name)
        license_types = LicenseType.order(:name).pluck(:name).uniq
        license_keys = LicenseKey.get_active_license_keys_by_state(params[:zip_code])
        marketing_referrals = MarketingReferral.active.order(:order)
        gender_identity = GenderIdentity.gi_values_for_menu

        render json: {
          locations: ActiveModelSerializers::SerializableResource.new(locations,
                                                                      each_serializer: FacilityFilterSerializer,
                                                                      postal_code: postal_code),
          expertises: expertise,
          concerns: concerns,
          populations: populations,
          interventions: interventions,
          special_cases: special_case,
          license_types: license_types,
          license_keys: license_keys,
          marketing_referrals: marketing_referrals,
          gender_identity: gender_identity
        }, status: :ok and return
      end

      private

      def filter_params
        filter_data_params = params.permit(:zip_code, :type_of_care)
        if postal_code.present?
          zip_codes = postal_code&.zip_code&.split
          zip_codes += postal_code&.nearby_zip_codes if postal_code.nearby_zip_codes.present?
          filter_data_params[:zip_code] = zip_codes
        end
        filter_data_params
      end

      def postal_code
        @postal_code ||= PostalCode.find_by(zip_code: params[:zip_code])
      end
    end
  end
end
