class HealthCheckController < ApplicationController
  skip_before_action :verify_jwt_token

  def index
    render json: { success: true }, status: :ok and return
  end
end
