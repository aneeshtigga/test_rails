namespace :zipcode do
  desc "Update postal code data on db"
  task update: :environment do
    puts "start time #{Time.zone.now}"
    PostalCode.update_zip_codes
    puts "end time #{Time.zone.now}"
  end
end
