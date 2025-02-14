module Api
  module V1
    class BookAppointmentsController < ApplicationController
      before_action :set_patient
      before_action :set_clinician_availability

      def create
        if @clinician_availability.present?
          
          patient_creation

          if @patient.reload.amd_patient_id.present?
            @patient.post_marketing_referral
            PatientsCustomDataWorker.perform_async(@patient.id)
            InsuranceWorker.perform_in(5.seconds, @patient.id)
            UploadInsuranceWorker.perform_in(5.seconds, @patient.id) if @patient.account_holder.booked_by == "patient"
          end
          
          service = BookAppointmentService.new(@clinician_availability, @patient, permitted_params[:booked_by])
          service.post_policy_holder
          patient_appointment = service.create_appointment!
          if patient_appointment.present?
            json_response = {
              patient_appointment: PatientAppointmentSerializer.new(patient_appointment),
              ccof_saved_to_amd: @patient.amd_save_ccof(permitted_params[:credit_card_info].to_h),
            }
            render json: json_response, status: :ok
          else
            render json: { message: "Appointment no longer available" }, status: :unprocessable_entity
          end
        else
          render json: { message: "Appointment no longer available" }, status: :unprocessable_entity
        end
      rescue StandardError => e
        ErrorLogger.report(e)

        render json: { message: "Error occured booking appointment", error: e.message },
               status: :unprocessable_entity and return
      end

      def permitted_params
        params.permit(:clinician_availability_key, :patient_id, :booked_by, credit_card_info: {})
      end

      def patient_creation
        if @patient.account_holder_relationship == "child"
          parent_patient_amd = parent_patient.amd_patient
          unless parent_patient_amd.present?
            # This being called without a present? condition was causing a lot of "More than one self relationship found" AMD errors
            parent_patient.create_amd_patient # if parent patient doesn't exist on amd
          else
            parent_patient.amd_patient_id = parent_patient_amd.id.gsub(/\D/, '').to_i
            parent_patient.save!
          end
        end
        
        amd_patient = @patient.amd_patient

        unless amd_patient.present?
          @patient.create_amd_patient
        else
          @patient.amd_patient_id = amd_patient.id.gsub(/\D/, '').to_i
          @patient.save!
        end
        @patient
      end

      private

      def set_clinician_availability
        @clinician_availability = ClinicianAvailability.find_by(clinician_availability_key: permitted_params[:clinician_availability_key])

        render json: { message: "Appointment no longer available" }, status: :not_found and return if @clinician_availability.nil?
      end

      def set_patient
        @patient = Patient.find_by(id: permitted_params[:patient_id])

        render json: { message: "Patient not found" }, status: :not_found and return if @patient.nil?
      end

      def parent_patient
        @patient.account_holder.self_patient
      end
    end
  end
end
