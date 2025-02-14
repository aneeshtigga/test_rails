class Expertise < ApplicationRecord
  default_scope { where(active: true) }
  has_many :clinician_expertises
  has_many :clinicians, through: :clinician_expertises

  validates :name, presence: true
end
