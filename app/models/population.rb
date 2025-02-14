class Population < ApplicationRecord
  default_scope { where(active: true) }
  has_many :clinician_populations
  has_many :clinicians, through: :clinician_populations

  validates :name, presence: true
end
