class EnableFlagLicenseKeyCalifornia < ActiveRecord::Migration[6.1]
  def change
    LicenseKey.find_by(key: 148377)&.update(active: true)
    SupportDirectory.find_by(license_key: 148377)&.update(location: "California",
                                                          support_hours: "8:30AM - 5:30PM PT", intake_call_in_number: "(925) 282-1778")
  end
end
