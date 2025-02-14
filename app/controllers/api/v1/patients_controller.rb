module Api
  module V1
    class PatientsController < ApplicationController
      before_action :set_patient, only: %i[update]

      def create
        patient = check_for_existing_patient

        patient.save!

        render json: { patient: patient }, status: :ok and return
      rescue ActiveRecord::RecordInvalid, Exception => e
        record = e.try(:record)

        render json: { message: "Error occurred in saving patient information",
                       error: e.message,
                       exists_in_amd: record&.exists_in_amd || record&.amd_patient_id ? true : false,
                       amd_patient_id: record&.amd_patient_id },
               status: :unprocessable_entity and return
      end

      def update
        # If patient exists in AMD it should not modified.
        raise ActiveRecord::RecordInvalid.new(@patient) if @patient.amd_patient_id.present?

        # If patient is a child, the email record is the same as the parent
        if @patient.account_holder_relationship == "child"
          @patient.email = @patient.account_holder.email
        end

        remove_concerns_ids if params.has_key?(:patient_concerns)
        remove_populations_ids if params.has_key?(:patient_populations)
        remove_interventions_ids if params.has_key?(:patient_interventions)

        clinician_match_flag = true
        clinician_match_flag = Clinician.match_with_special_case(params[:clinician_id], params[:special_case_id]) if (params[:clinician_id].present? && params[:clinician_id].present?)

        unless patient_populations.nil?
          patient_populations.each do |population|
            unless @patient.populations.find_by(id: population["population_id"]).present?
              @patient.populations << Population.find_by(id: population["population_id"])
            end
          end
        end

        unless patient_interventions.nil?
          patient_interventions.each do |intervention|
            unless @patient.interventions.find_by(id: intervention["intervention_id"]).present?
              @patient.interventions << Intervention.find_by(id: intervention["intervention_id"])
            end
          end
        end

        unless patient_concerns.nil?
          patient_concerns.each do |concern|
            unless @patient.concerns.find_by(id: concern["concern_id"]).present?
              @patient.concerns << Concern.find_by(id: concern["concern_id"])
            end
          end
        end

        @patient.update!(patient_params)

        render json: { patient: @patient, clinician_match_flag: clinician_match_flag }, status: :ok and return
      rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => e
        render_error(e)
      end

      private

      # rubocop:disable Metrics/MethodLength

      def patient_concerns
        params[:patient_concerns]
      end

      def patient_populations
        params[:patient_populations]
      end

      def patient_interventions
        params[:patient_interventions]
      end

      def patient_params
        params.permit(:first_name,
                      :last_name,
                      :preferred_name,
                      :date_of_birth,
                      :gender,
                      :gender_identity,
                      :phone_number,
                      :referral_source,
                      :pronouns,
                      :about,
                      :account_holder_relationship,
                      :account_holder_id,
                      :credit_card_on_file_collected,
                      :intake_status,
                      :special_case_id,
                      :provider_id,
                      :referring_provider_name,
                      :referring_provider_phone_number,
                      search_filter_values: {}
                      )
      end
      
      # rubocop:enable Metrics/MethodLength

      def set_patient
        @patient = Patient.find_by(id: params[:id])

        render json: { message: "Patient not found" }, status: :not_found and return if @patient.nil?
      end

      def render_error(error)
        render json: { message: "Error occured in saving patient information", error: error.message },
               status: :unprocessable_entity and return
      end

      def remove_concerns_ids
        @patient&.concerns&.delete_all
      end

      def remove_populations_ids
        @patient&.populations&.delete_all
      end

      def remove_interventions_ids
        @patient&.interventions&.delete_all
      end

      def check_for_existing_patient
        if patient_params["account_holder_relationship"] == "self"
          patient = Patient.where(
            'LOWER(first_name) = ? AND LOWER(last_name) = ? AND date_of_birth = ? AND LOWER(email) = ?',
            patient_params["first_name"].downcase,
            patient_params["last_name"].downcase,
            patient_params["date_of_birth"].to_date.strftime("%Y-%m-%d"),
            patient_params["email"].downcase
          ).first_or_initialize
        else
          # Child (belongs to an account holder)
          patient = Patient.where(
            'LOWER(first_name) = ? AND LOWER(last_name) = ? AND date_of_birth = ? AND account_holder_id = ?',
            patient_params["first_name"].downcase,
            patient_params["last_name"].downcase,
            patient_params["date_of_birth"].to_date.strftime("%Y-%m-%d"),
            patient_params["account_holder_id"]
          ).first_or_initialize
        end

        # If patient exists in AMD it should not modified.
        raise ActiveRecord::RecordInvalid.new(patient) if patient.amd_patient_id.present?

        patient.update!(patient_params)
        patient
      end
    end
  end
end
