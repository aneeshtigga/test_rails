# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  controller do
    before_action :authorize_dashboard

    def authorize_dashboard
      authorize! :manage, Clinician
    end

    def index
      if current_user
        redirect_to activeadmin_insurances_path
      else
        redirect_to user_saml_omniauth_authorize_path
      end
    end
  end

end
