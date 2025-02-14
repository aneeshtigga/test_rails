# == Schema Information
# Schema version: 20230330105145
#
# Table name: license_keys
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  cbo        :bigint           indexed
#  key        :bigint           not null, indexed
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_license_keys_on_cbo  (cbo)
#  index_license_keys_on_key  (key) UNIQUE
#
class LicenseKey < ApplicationRecord
  has_many :license_key_rules
  validates :key, presence: true

  scope :get_active_license_keys_by_state, ->(zip_code) {
    joins("join clinician_addresses on clinician_addresses.office_key = license_keys.key").where(active: true).where("clinician_addresses.state = ?", PostalCode.get_state(zip_code)).order(:key).pluck(:key).uniq
  }
end
