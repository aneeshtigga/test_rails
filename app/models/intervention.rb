class Intervention < ApplicationRecord
  default_scope { where(active: true) }
  has_many :clinician_interventions
  has_many :clinicians, through: :clinician_interventions

  validates :name, presence: true
end
