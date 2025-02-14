class EnableFlagForCo < ActiveRecord::Migration[6.1]
  def change
    # Colorado
    LicenseKey.find_by(key: 146010)&.update(active: true);
    SupportDirectory.find_or_create_by(license_key: 146010) do |support_directory|
      support_directory.location = "Colorado"
      support_directory.support_hours = "8:00AM - 5:00PM MT"
      support_directory.intake_call_in_number = "(970) 310-3406"
      support_directory.cbo = 150622
    end
  end
end
