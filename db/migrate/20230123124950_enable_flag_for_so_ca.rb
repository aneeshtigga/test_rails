class EnableFlagForSoCa < ActiveRecord::Migration[6.1]
  def change
    # Southern California - 144896
    LicenseKey.find_by(key: 144896)&.update(active: true)
    SupportDirectory.find_or_create_by(license_key: 144896) do |support_directory|
      support_directory.location = "California"
      support_directory.support_hours = "8:00AM - 5:00PM PT"
      support_directory.intake_call_in_number = "(562) 431-8822"
      support_directory.cbo = 150153
    end

    # Southern California - 143255
    LicenseKey.find_by(key: 143255)&.update(active: true)
    SupportDirectory.find_or_create_by(license_key: 143255) do |support_directory|
      support_directory.location = "California"
      support_directory.support_hours = "8:00AM - 5:00PM PT"
      support_directory.intake_call_in_number = "(858) 279-1223"
      support_directory.cbo = 150153
    end
  end
end
