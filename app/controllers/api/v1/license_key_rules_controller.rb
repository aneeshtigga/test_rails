module Api
  module V1
    class LicenseKeyRulesController < ApplicationController
      def index
        insurance_skip_option_flag = LicenseKeyRule.get_insurance_rule_skip_flag(params[:license_key])
        enable_credit_card_on_file = LicenseKeyRule.get_is_credit_card_enabled_on_file(params[:license_key])
        disable_skip_credit_card = LicenseKeyRule.get_is_credit_card_skip_disabled(params[:license_key])
        render json: {
          insurance_skip_option_flag: insurance_skip_option_flag,
          enable_credit_card_on_file: enable_credit_card_on_file,
          disable_skip_credit_card: disable_skip_credit_card
        }, status: :ok
      end
    end
  end
end
