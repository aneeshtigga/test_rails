class EnableFlagForKs < ActiveRecord::Migration[6.1]
  def change
    # Kansas
    LicenseKey.find_by(key: 154228)&.update(active: true);
    SupportDirectory.find_or_create_by(
      license_key: 154228,
      location: "Kansas",
      support_hours: "8:00AM - 5:00PM CT",
      intake_call_in_number: "(913) 327-7505",
      cbo: 150686
    )
  end
end
