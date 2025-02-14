namespace :support_directories do
  desc "Add support directory for NY license key "
  task add_support_142175: :environment do
    SupportDirectory.where(
      cbo: "138690",
      license_key: "142175",
      location: "",
      support_hours: "8:00AM-6:00PM EST",
      intake_call_in_number: "844-468-5050",
      established_patients_call_in_number: "844-468-5050",
      follow_up_url: "https://patientportal.advancedmd.com/142175/account/logon"
    ).first_or_create!
  end
end
