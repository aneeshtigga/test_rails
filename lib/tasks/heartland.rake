namespace :heartland do
  desc "Get a Heartland single use token for credit cards on file"
  task get_token: :environment do
    include Tasks::Colorize

    puts yellow("Start Time #{Time.zone.now}")

    api_key = Rails.application.credentials.dig(:heartland, :api_key)
    cc_data = {
      number: 4111_1111_1111_1111,
      cvc: "123",
      exp_month: "12",
      exp_year: "2025"
    }
    
    client = Heartland::Client.new(api_key: api_key)
    puts green("Token: #{client.get_token(cc_data)}")
    
    puts yellow("End Time #{Time.zone.now}")
  end
end
