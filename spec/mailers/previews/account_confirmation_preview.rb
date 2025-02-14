# Preview all emails at http://localhost:3000/rails/mailers/account_confirmation
class AccountConfirmationPreview < ActionMailer::Preview
  def send_confirmation
    mail = AccountConfirmationMailer.send_confirmation(AccountHolder.last.id)
    Premailer::Rails::Hook.perform(mail)
  end
end 
