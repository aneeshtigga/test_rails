class EnableFlagLicenseKeyMaineNewHampshireRhodeIsland < ActiveRecord::Migration[6.1]
  def change
    #New Hampshire and Maine
    LicenseKey.find_by(key: 140126)&.update(active: true)
    SupportDirectory.find_by(license_key: 140126)&.update(location: "Maine and New Hampshire",
      support_hours: "For New Hampshire, 8:00AM - 6:00PM ET.  For Maine, 8:00AM - 5:00PM ET",
      intake_call_in_number: "For New Hampshire, (603) 689-7890.  For Maine, (207) 774-8700")

    #Rhode Island
    LicenseKey.find_by(key: 151046)&.update(active: true)
    SupportDirectory.find_or_create_by(
      license_key: 151046, 
      location: "Rhode Island",
      support_hours: "8:00AM - 5:00PM ET",
      intake_call_in_number: "(401) 785-0040",
      cbo: 150706)
  end
end
