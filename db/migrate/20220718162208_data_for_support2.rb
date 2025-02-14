class DataForSupport2 < ActiveRecord::Migration[6.1]
  def change
    # Missouri
    LicenseKey.find_by(key: 140753)&.update(active: true)
    SupportDirectory.find_by(license_key: 140753)&.update(location: 'Missouri', 
      support_hours: '8:00AM - 4:30PM CT', intake_call_in_number: '(636) 939-2550')

    # Delaware
    LicenseKey.find_by(key: 148542)&.update(active: true)
    SupportDirectory.find_by(license_key: 148542)&.update(location: 'Delaware', 
      support_hours: '8:00AM - 5:00PM ET', intake_call_in_number: '(302) 224-1400')

    # Texas
    LicenseKey.find_by(key: 136732)&.update(active: true)
    SupportDirectory.find_by(license_key: 136732)&.update(location: 'Texas', 
      support_hours: '8:00AM - 6:00PM CT', intake_call_in_number: '(844) 824-8775')
  end
end
