class Api::V1::CancellationReasonsController < ApplicationController
  def index
    cancellation_reasons = CancellationReason.select(:id, :reason, :reason_equivalent)
    render json: cancellation_reasons
  end
end
