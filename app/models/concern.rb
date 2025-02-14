class Concern < ApplicationRecord
  default_scope { where(active: true) }
  has_many :clinician_concerns
  has_many :clinicians, through: :clinician_concerns

  validates :name, presence: true
  enum age_type: {self: 0, child: 1, both: 2}

  scope :with_age_types, -> (age_type) { where(age_type: [age_type, "both"]) }
  scope :has_age_type, -> { where.not(age_type: nil) }
end
