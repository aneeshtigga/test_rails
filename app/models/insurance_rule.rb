class InsuranceRule < ApplicationRecord
  has_many :license_key_rules, as: :ruleable
end
