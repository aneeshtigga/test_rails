module Api
  module V1
    class AppointmentHealthChecksController < ApplicationController
      def index
        render json: { success: AppointmentMonitor.within_threshold?, threshold: AppointmentMonitor.threshold }, status: :ok and return
      end
    end
  end
end