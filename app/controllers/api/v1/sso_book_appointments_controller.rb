module Api
  module V1
    class SsoBookAppointmentsController < ApplicationController
      skip_before_action :verify_jwt_token
      skip_before_action :verify_authenticity_token
      before_action :validate_availability, only: %i[create] 

      def create
        service = BookAppointmentService.new(clinician_availability, patient, permitted_params[:booked_by])
        patient_appointment = service.create_appointment!
        if patient_appointment.present?
          render json: { patient_appointment: PatientAppointmentSerializer.new(patient_appointment) }, status: :ok
        else
          render json: { message: "Appointment no longer available" }, status: :unprocessable_entity
        end
      rescue StandardError => error
        ErrorLogger.report(error.message)
        render json: { message: "Error occured booking appointment", error: error.message },
          status: :unprocessable_entity and return
      end

      def validate_availability
        render json: { message: "Session expired" }, status: :unauthorized and return unless authenticated?  
        render json: { message: "Patient not found" }, status: :not_found and return if patient.nil?
        render json: { message: "Appointment no longer available" }, status: :not_found and return if clinician_availability.nil?
      end

      def permitted_params
        params.permit(:clinician_availability_key, :patient_id, :booked_by)
      end

      private
       
      def selected_patient_id
        session[:selected_patient_id]
      end

      def authenticated?
        !selected_patient_id.nil?
      end

      def clinician_availability
        @clinician_availability ||= ClinicianAvailability.existing_patient_clinician_availabilities.find_by(clinician_availability_key: permitted_params[:clinician_availability_key])
      end

      def patient
        @patient ||= Patient.find_by(amd_patient_id: permitted_params[:patient_id])
      end
    end
  end
end
