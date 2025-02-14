module Api
  module V1
    class ClinicianAddressCheckController < ApplicationController
      def index
        clinicians = Clinician.active.with_none_active_address.select('clinicians.id')
        render json: { clinician_ids: clinicians.pluck(:id), clinician_count: clinicians.size }, status: :ok and return
      end
    end
  end
end
