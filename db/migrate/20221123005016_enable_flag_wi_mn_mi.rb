class EnableFlagWiMnMi < ActiveRecord::Migration[6.1]
  def change
    # Wisconsin
    LicenseKey.find_by(key: 149809)&.update(active: true);
    SupportDirectory.find_or_create_by(
      license_key: 149809, 
      location: "Wisconsin",
      support_hours: "8:00AM - 4:30PM CT",
      intake_call_in_number: "(262) 789-1191",
      cbo: 150152
    )

    # Minnesota
    LicenseKey.find_by(key: 149810)&.update(active: true)
    SupportDirectory.find_or_create_by(
      license_key: 149810, 
      location: "Minnesota",
      support_hours: "8:00AM - 4:45PM CT",
      intake_call_in_number: "(612) 924-3807",
      cbo: 150152
    )

    # Michigan
    LicenseKey.find_by(key: 150339)&.update(active: true)
    SupportDirectory.find_or_create_by(
      license_key: 150339, 
      location: "Michigan",
      support_hours: "8:00AM - 5:30PM ET",
      intake_call_in_number: "(517) 882-3732",
      cbo: 150152
    )

    # Washington change phone number 
    SupportDirectory.find_by(license_key: 147765)&.update(intake_call_in_number: "(253) 752-7320")
  end
end
