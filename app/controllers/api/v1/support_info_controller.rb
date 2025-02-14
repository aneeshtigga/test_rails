module Api
  module V1
    class SupportInfoController < ApplicationController
      def support_by_license_key
        if support_info.blank?
          return render json: { message: "No support contact available for the provided office code" },
                 status: :not_found
        end

        render json: support_info, marketing_referral: marketing_referral, each_serializer: SupportInfoSerializer, status: :ok
      end

      private

      def license_param
        params.permit(:office_code, :marketing_referral)
      end

      def support_info
        @support_info ||= SupportDirectory.where(license_key: license_param[:office_code]).order(:id)
      end

      def marketing_referral
        MarketingReferral.find_by(display_marketing_referral: license_param[:marketing_referral]) if license_param[:marketing_referral].present?
      end
    end
  end
end
