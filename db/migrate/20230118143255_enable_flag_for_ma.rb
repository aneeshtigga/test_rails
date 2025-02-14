class EnableFlagForMa < ActiveRecord::Migration[6.1]
  def change
    # Massachusetts
    LicenseKey.find_by(key: 139414)&.update(active: true)
    SupportDirectory.find_or_create_by(license_key: 139414) do |support_directory|
      support_directory.location = "Massachusetts"
      support_directory.support_hours = "8:00AM - 5:00PM ET"
      support_directory.intake_call_in_number = "(781) 551-0999"
      support_directory.cbo = 138690
    end

    # Massachusetts
    LicenseKey.find_by(key: 147611)&.update(active: true)
    SupportDirectory.find_or_create_by(license_key: 147611) do |support_directory|
      support_directory.location = "Massachusetts"
      support_directory.support_hours = "8:00AM - 5:00PM ET"
      support_directory.intake_call_in_number = "(781) 551-0999"
      support_directory.cbo = 138690
    end
  end
end


