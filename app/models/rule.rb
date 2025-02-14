class Rule < ApplicationRecord
  has_many :license_key_rules, as: :ruleable

  validates :key, presence: true
  validates :value, presence: true
end
