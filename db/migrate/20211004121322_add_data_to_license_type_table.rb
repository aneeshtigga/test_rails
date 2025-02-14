class AddDataToLicenseTypeTable < ActiveRecord::Migration[6.1]
  def change
    if !(Rails.env.development? || Rails.env.test?)
      ClinicianMart.all.map{|x| x.license_type.to_s.split(",")}.flatten.uniq.each do |license_type|
        LicenseType.find_or_create_by(name: license_type.squish)
      end

      ClinicianMart.all.each do |dw_clinician|
        clinician = Clinician.find_by(provider_id: dw_clinician.clinician_id, license_key: dw_clinician.license_key)
        next if (clinician.blank? || clinician.deleted_at.present?)
        clinician.update(license_type: dw_clinician.license_type)
        clinician.clinician_license_types.map(&:mark_for_destruction)
        license_types = if dw_clinician.license_type.present?
                        dw_clinician.license_type.split(",").map do |license_type|
                          LicenseType.find_by(name: license_type.strip)
                        end
                      else
                        []
                      end

        clinician.license_types = license_types
        clinician.save!
      end
    end
  end
end
