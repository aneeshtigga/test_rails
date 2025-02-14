class DataForSupport < ActiveRecord::Migration[6.1]
  def change
    # Maryland
    LicenseKey.find_by(key: 149037)&.update(active: true)
    SupportDirectory.find_by(license_key: 149037)&.update(location: 'Maryland', 
      support_hours: '8:00AM - 5:00PM ET', intake_call_in_number: '(410) 757-2077')

    # Idaho
    LicenseKey.find_by(key: 148382)&.update(active: true)
    SupportDirectory.find_by(license_key: 148382)&.update(location: 'Idaho', 
      support_hours: '8:00AM - 5:00PM MT', intake_call_in_number: '(208) 209-2432')

    # Washington
    LicenseKey.find_by(key: 147765)&.update(active: true)
    SupportDirectory.find_by(license_key: 147765)&.update(location: 'Washington', 
      support_hours: '8:00AM - 5:00PM PT', intake_call_in_number: '(206) 420-5416')
  end
end
