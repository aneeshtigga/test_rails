module Api
  module V1
    class EmergencyContactController < ApplicationController

      def create
        emergency_contact = EmergencyContact.find_or_initialize_by(patient_id: params[:patient_id])
        emergency_contact.update(
          first_name: params[:first_name],
          last_name: params[:last_name],
          phone: params[:phone],
          relationship_to_patient: params[:relationship_to_patient],
          patient_id: params[:patient_id]
        )
        emergency_contact.save!

        render json: { emergency_contact: emergency_contact.id }, status: :ok and return
      rescue ActiveRecord::RecordInvalid, Exception => e
        record = e.try(:record)

        render json: { message: "Error occurred while saving emergency contact",
                       error: e.message },
               status: :unprocessable_entity and return
      end

      def show
        emergency_contact = EmergencyContact.find_by(patient_id: params[:patient_id])
        render json: { message: "Emergency contact not found" }, status: :not_found and return if emergency_contact.blank?

        render json: emergency_contact, status: :ok and return
      end

      private

      def permitted_params
        params.permit(:first_name,
                      :last_name,
                      :phone,
                      :relationship_to_patient,
                      :patient_id
        )
      end
    end
  end
end
