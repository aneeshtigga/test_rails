require "sidekiq/web"
require "sidekiq/cron/web"

# Configure Sidekiq-specific session middleware

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use Rails.application.config.session_store, Rails.application.config.session_options

Rails.application.routes.draw do

  scope :api, as: nil do
    ActiveAdmin.routes(self)

    devise_for :users, controllers: {
      omniauth_callbacks: "omniauth_callbacks",
    },
    skip: [:sessions, :registrations, :passwords]

    get "login", to: redirect("/api/users/auth/saml")
  end

  namespace :obie, defaults: { format: "json" } do
    namespace :api do
      namespace :v2 do
        get "clinicians", to: "clinicians#index"
        get "clinician_count_by_zip", to: "zipcode#clinician_count"
        put "account_holders/:id/send_confirmation_email", to: "account_holders#send_confirmation_email"
        # FIXME: the following urls should point to v2 controller
        get "clinician/:id", to: "clinicians#show", defaults: { app_name: "obie" }
        get "filter_data", to: "/api/v1/filter_data#index"
        get "support_info", to: "/api/v1/support_info#support_by_license_key"
        get "clinician_availabilities", to: "/api/v1/clinician_availabilities#index"

        get "validate_zip", to: "zipcode#validate_zip"
      end
    end
  end
  
  namespace :abie, defaults: { format: "json" } do
    namespace :api do
      namespace :v2 do
        get "clinicians", to: "clinicians#index"
        put "account_holders/:id/send_confirmation_email", to: "account_holders#send_confirmation_email"
        # FIXME: the following urls should point to v2 controller
        get "clinician/:id", to: "clinicians#show"
        get "filter_data", to: "/api/v1/filter_data#index"
        get "support_info", to: "/api/v1/support_info#support_by_license_key"
        get "clinician_availabilities", to: "/api/v1/clinician_availabilities#index"

        get "validate_zip", to: "zipcode#validate_zip"
      end
    end
  end

  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :book_appointments, only: [:create]
      resources :sso_book_appointments, only: [:create]
      get "validate_zip", to: "zipcode#validate_zip"
      post "generate_token", to: "authentication#generate_token"
      get "clinicians", to: "clinicians#index"
      get "clinician_availabilities", to: "clinician_availabilities#index"
      get "/clinician/:id", to: "clinicians#show"
      resources :account_holders, only: %i[create update] do
        member do
          put :selected_slot_info, to: "selected_slot_info#update"
        end
      end
      get "selected_slot_info", to: "selected_slot_info#show"
      resources :patient_intake_status, only: [:update]
      resources :resend_account_verification_email, only: [:update]
      resources :resend_booking_appointment_email, only: [:update]
      resources :patient_appointments, only: [:show]
      resources :emergency_contact, only: %i[create show], path: "/patients/emergency_contact"
      resources :patients, only: %i[create update] do
        member do
          put :insurance_coverages, to: "patient_insurance_coverages#update"
          put :patient_addresses, to: "patient_addresses#update"
          put :insurance_card, to: "patient_insurance_card#update"
          post :insurance_card, to: "patient_insurance_card#update"
        end
      end
      resources :sso_clinician, only: [] do
        member do
          get :modalities, to: "sso_clinician#modalities"
          get :locations, to: "sso_clinician#locations"
        end
      end
      put "confirm_account", to: "account_confirmation#update"
      get "confirm_account", to: "account_confirmation#update"
      resources :appointment_cancellations, only: %i[update]
      resources :filter_data, only: :index
      
      post "auth", to: "sso_auth#index"
      delete "logout", to: "sso_auth#destroy"
      get "patient_info", to: "sso_patient_info#index"
      get "existing_patient_information", to: "sso_patient_information#index"
      get "support_info", to: "support_info#support_by_license_key"
      get "insurances", to: "insurance#index"
      get "license_key_rules", to: "license_key_rules#index"
      resources :sso_clinician_availabilities, only: :index
      resources :sso_insurance, only: :index
      resources :appointment_health_checks, only: :index
      resources :clinician_address_check, only: :index
      resources :sso_patient_insurance, only: :create
      
      get "/cancellation_reasons", to: "cancellation_reasons#index"
      post "/cancellations", to: "cancellations#create"
    end
  end
  
  get "/health-check", to: "health_check#index"

  mount Sidekiq::Web, at: "/api/sidekiq"
  root to: "activeadmin/dashboard#index"
end
