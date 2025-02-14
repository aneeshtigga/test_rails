namespace :data_migration do
  desc "Changes in postgres data"
  task add_phreesia_license_keys: :environment do
    include Tasks::Colorize

    puts yellow("Adding Phreesia License Keys")

    [140094,140097,140098, 154228, 140103, 140753].each do |license_key|
      Phreesia.create!(license_key: license_key)
    end
    puts green("Completed adding phreesia license keys.")
  end

end
