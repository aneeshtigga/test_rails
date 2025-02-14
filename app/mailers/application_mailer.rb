class ApplicationMailer < ActionMailer::Base
  default from: "noreply@lifestance.com"
  layout "mailer"

  has_history
end
