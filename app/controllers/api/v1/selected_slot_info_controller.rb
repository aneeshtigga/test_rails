module Api
  module V1
    class SelectedSlotInfoController < ApplicationController
      before_action :set_account_holder, only: %i[update show]

      def show
        render json: render_slot_info, status: :ok
      end

      def update
        @account_holder.update!(selected_slot_info: permitted_params[:selected_slot_info])
        @account_holder.reload
        render json: render_slot_info, status: :ok
      rescue StandardError => e
        ErrorLogger.report(e)
        render_error(e) 
      end

      private

      def permitted_params
        params.permit(:id, selected_slot_info: {})
      end

      def account_holder_by_id
        @account_holder ||= AccountHolder.find_by(id: permitted_params[:id])
      end

      def render_slot_info
        { account_holder_id: @account_holder.id, selected_slot_info: @account_holder.selected_slot_info }
      end

      def render_account_not_found
        render json: { message: "AccountHolder not found" }, status: :not_found and return
      end

      def set_account_holder
        account_holder_by_id if permitted_params[:id].present?
        render_account_not_found if @account_holder.nil?
      end

      def render_error(error)
        render json: errors(error),
               status: :unprocessable_entity and return
      end

      def errors(error)
        { message: "Error occured in saving account holder information",
          error: error.message }
      end
    end
  end
end
