class FacilityAcceptedInsurance < ApplicationRecord
  default_scope -> { where(active: true) }
  
  validates :insurance_id, presence: true
  has_many :insurance_coverages

  scope :with_insurance_name, ->(insurance) { includes(:insurance).where(insurances: { name: insurance }) }

  scope :with_clinician_address, ->(provider_id, license_key, facility_id) {includes(:clinician_address).where(clinician_addresses: {facility_id: facility_id, provider_id: provider_id, office_key: license_key})}

  belongs_to :insurance
  belongs_to :clinician_address
  belongs_to :clinician
end
