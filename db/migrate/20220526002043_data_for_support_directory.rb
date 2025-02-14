class DataForSupportDirectory < ActiveRecord::Migration[6.1]
  def change
    # Indiana
    LicenseKey.find_by(key: 140099)&.update(active: true)
    SupportDirectory.find_by(license_key: 140099)&.update(location: 'Indiana', 
      support_hours: '8:00AM - 5:00PM ET', intake_call_in_number: '(812) 247-8010')

    # Kentucky
    LicenseKey.find_by(key: 140103)&.update(active: true)
    SupportDirectory.find_by(license_key: 140103)&.update(location: 'Kentucky', 
      support_hours: '8:00AM - 4:30PM ET', intake_call_in_number: '(859) 214-7440')

    # Kentucky 2
    LicenseKey.find_by(key: 140097)&.update(active: true)
    SupportDirectory.find_by(license_key: 140097)&.update(location: 'Kentucky', 
      support_hours: '8:00AM - 4:30PM ET', intake_call_in_number: '(502) 313-6880')
  end
end
