module Api
  module V1
    class ResendAccountVerificationEmailController < ApplicationController
      before_action :set_account_holder, only: %i[update]

      def update
        @account_holder.update!(email: params[:email], email_verified: false)
        render json: { account_holder: @account_holder }, status: :ok and return
      rescue ActiveRecord::RecordInvalid => e
        render_error(e)
      end

      private

      def set_account_holder
        @account_holder = AccountHolder.find_by(id: params[:id])

        render json: { message: "Account Holder not found" }, status: :not_found and return if @account_holder.nil?
      end

      def booked_by
        params[:booked_by]
      end


     def render_error(error)
        render json: { message: "Error occured in saving account holder information", error: error.message },
               status: :unprocessable_entity and return
      end
    end
  end
end
