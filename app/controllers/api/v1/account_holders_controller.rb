module Api
  module V1
    class AccountHoldersController < ApplicationController
      before_action :check_for_office_key, only: %i[create]
      before_action :set_account_holder, only: %i[update]

      def create
        amd_account_lookup = AmdAccountLookupService.new(account_holder_params, get_office_code)
        
        existing_accounts = amd_account_lookup.existing_accounts
        patient_exists_on_amd = amd_account_lookup.amd_search_for_patient

        if existing_accounts[:responsible_party_patients].present? && patient_exists_on_amd
          render json: {
            message: "Account holder already exists",
            exists_in_amd: true,
            patient_portal_url: "https://patientportal.advancedmd.com/#{get_office_code}/account/logon",
            existing_accounts: existing_accounts
          }, status: :unprocessable_entity and return
        end

        unless patient_exists_on_amd
          account_holder = create_account!
          # account_holder.send_verification_email if account_holder.present? && !(booked_by.present? && booked_by == "admin")
        end

        render json: { account_holder: AccountHolderSerializer.new(account_holder) }, status: :created and return
      rescue StandardError => e
        ErrorLogger.report(e) unless (e.message.gsub("\"", '').include? "Duplicate name/DOB found")
        render_error(e)
      end

      def update
        @account_holder.update!(account_holder_params)
        render json: { account_holder: @account_holder }, status: :ok and return
      rescue ActiveRecord::RecordInvalid => e
        render_error(e)
      end

      private

      def create_account!
        account_holder = check_for_existing_account_holder
        AccountHolder.transaction do
          account_holder.save!
          create_self_patient(account_holder)
          account_holder
        end
      end

      def set_account_holder
        @account_holder = AccountHolder.find_by(id: params[:id])
        render json: { message: "Account Holder not found" }, status: :not_found and return if @account_holder.nil?
      end

      def account_holder_params
        params.permit(:first_name, :last_name, :date_of_birth, :phone_number, :email, :source, :gender, 
                      :gender_identity, :receive_email_updates, :provider_id, :pronouns, :about, :booked_by,
                      search_filter_values: {})
      end

      def render_error(error)
        render json: errors(error),
               status: :unprocessable_entity and return
      end

      def get_office_code
        clinician_address = ClinicianAddress.find_by(id: clinician_address_id)
        clinician_address&.office_key
      end

      def clinician_address_id
        if params[:search_filter_values].present? && params[:search_filter_values]["clinician_address_id"].present?
          params[:search_filter_values]["clinician_address_id"]
        end
      end

      def zip_code
        if params[:search_filter_values].present? && params[:search_filter_values]["zip_codes"].present?
          params[:search_filter_values]["zip_codes"]
        end
      end

      def booked_by
        params[:booked_by]
      end

      def errors(error)
        error_messages = { message: "Error occured in saving account holder information",
                           error: error.message,
                           exists_in_amd: true,
                           patient_portal_url: "https://patientportal.advancedmd.com/#{get_office_code}/account/logon"
                          }

        error_messages
      end

      def create_self_patient(account_holder)
        patient = Patient.find_by(
          'LOWER(first_name) = ? AND LOWER(last_name) = ? AND date_of_birth = ? AND LOWER(email) = ?',
          account_holder.first_name.downcase,
          account_holder.last_name.downcase,
          Date.strptime(account_holder.date_of_birth, "%m/%d/%Y"),
          account_holder.email.downcase
        )
        unless patient.present? 
            account_holder.patients.create!(
            first_name: account_holder.first_name,
            last_name: account_holder.last_name,
            date_of_birth: account_holder.date_of_birth,
            email: account_holder.email,
            gender: account_holder.gender,
            gender_identity: account_holder.gender_identity,
            account_holder_relationship: :self,
            account_holder_id: account_holder.id,
            referral_source: account_holder.source,
            phone_number: account_holder.phone_number,
            pronouns: account_holder.pronouns,
            about: account_holder.about,
            search_filter_values: account_holder.search_filter_values,
            office_code: get_office_code,
            provider_id: account_holder.provider_id
          )
        else
          account_holder.patients << patient
        end
      end

      def check_for_office_key
        raise "Missing office code" if get_office_code.nil?
      end

      def check_for_existing_account_holder
        account_holder = AccountHolder.find_or_initialize_by(first_name: account_holder_params["first_name"],
                                                             last_name: account_holder_params["last_name"],
                                                             date_of_birth: account_holder_params["date_of_birth"])
        account_holder.update!(account_holder_params)
        account_holder
      end
    end
  end
end
