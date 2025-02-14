class ClinicianLicenseType < ApplicationRecord
  belongs_to :clinician
  belongs_to :license_type
end
