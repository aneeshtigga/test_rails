class EnableFlagLicenseKeyScOk < ActiveRecord::Migration[6.1]
  def change
    LicenseKey.find_by(key: 149035)&.update(active: true)
    SupportDirectory.find_by(license_key: 149035)&.update(location: "South Carolina",
                                                          support_hours: "8:30AM - 5:00PM ET", intake_call_in_number: "(843) 501-1099")

    LicenseKey.find_by(key: 148561)&.update(active: true)
    SupportDirectory.find_by(license_key: 148561)&.update(location: "Oklahoma",
                                                          support_hours: "8:00AM - 5:00PM CT", intake_call_in_number: "(405) 378-2727")
  end
end
