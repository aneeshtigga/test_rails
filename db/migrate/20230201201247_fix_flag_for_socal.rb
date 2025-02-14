class FixFlagForSocal < ActiveRecord::Migration[6.1]
  def change

    # destroy previously created support directories
    SupportDirectory.where(license_key: 144896, follow_up_url: nil).each do |sd|
      sd.destroy
    end
    
    SupportDirectory.where(license_key: 143255, follow_up_url: nil).each do |sd|
      sd.destroy
    end
    
    # Southern California - 144896
    LicenseKey.find_by(key: 144896)&.update(active: true)
    SupportDirectory.find_by(license_key: 144896)&.update({
      location: "California",
      support_hours: "8:00AM - 5:00PM PT",
      intake_call_in_number: "(562) 431-8822",
      cbo: 150153
    })
    
    # Southern California - 143255
    LicenseKey.find_by(key: 143255)&.update(active: true)
    SupportDirectory.find_by(license_key: 143255)&.update({
      location: "California",
      support_hours: "8:00AM - 5:00PM PT",
      intake_call_in_number: "(858) 279-1223",
      cbo: 150153
    })
  end
end
