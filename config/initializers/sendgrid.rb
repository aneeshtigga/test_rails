if Rails.application.credentials.sendgrid.present?
  ActionMailer::Base.smtp_settings = {
    domain:         "lifestance.com",
    address:        "smtp.sendgrid.net",
    port:            587,
    authentication: :plain,
    user_name:      "apikey",
    password:       Rails.application.credentials.sendgrid[:api_key]
  }
end