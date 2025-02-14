class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token
  skip_authorization_check 

  def saml
    begin
      unless current_user
        # Find the user with email, or create a new one with name
        unless user = User.find_by(email: data(:email).downcase)
          user = User.create!(
            first_name: data(:first_name),
            last_name: data(:last_name),
            email: data(:email).downcase,
            saml_uid: request.env['omniauth.auth'].uid,
          )
        end

        sign_in user
      end

      redirect_to activeadmin_dashboard_path
    end
  end 

  def failure
    raise "OmniauthCallbacksController failure - unable to process omniauth callback"
  end

  def metadata_attributes(key)
    @metadata ||= {
      name: "http://schemas.microsoft.com/identity/claims/displayname",
      first_name: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname",
      last_name: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname",
      email: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
    }

    @metadata[key]
  end

  def data(key)
    @info ||= request.env['omniauth.auth'].extra.raw_info

    @info[metadata_attributes(key)]
  end
end