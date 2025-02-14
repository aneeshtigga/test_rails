namespace :amd do
  desc "Save a patient to credit card to AMD"
  task save_ccof: :environment do
    include Tasks::Colorize

    puts yellow("Start Time #{Time.zone.now}")

    patient = nil
    # find a patient with an AMD responsible_party_id but who has not had their credit card saved to AMD
    AccountHolder.where.not(responsible_party_id: nil).each do |account_holder|
      candidate = account_holder.patients.compact.first
      
      next unless candidate
      next unless candidate.office_code == 996075
      next unless account_holder.responsible_party&.amd_id # skip if responsible party does not have an AMD id
      next if candidate.credit_card_on_file_collected
      next if candidate.amd_has_ccof? # skip if patient already has a credit card saved to AMD

      patient = candidate
      break
    end

    raise "No patient found" unless patient

    api_key = Rails.application.credentials.dig(:heartland, :api_key)
    client = Heartland::Client.new(api_key: api_key)
    heartland_token = client.get_token({
      number: 4111_1111_1111_1111,
      cvc: "123",
      exp_month: "12",
      exp_year: "2030"
    })

    credit_card_params = {
      creditCardToken: heartland_token,
      lastFourDigits: "1111",
      expirationMonth: 12,
      expirationYear: 2025,
      zipCode: "75024",
      responsiblePartyId: patient.account_holder.responsible_party.amd_id,    
    }
    
    puts green("Patient ID: #{patient.id}")
    puts green("AMD CCOF Saved? #{patient.amd_save_ccof(credit_card_params)}")
    
    puts yellow("End Time #{Time.zone.now}")
  end

end
