class SpecialCase < ApplicationRecord
   include SoftDeletable

   has_many :patients
   has_many :clinician_special_cases, dependent: :destroy
   has_many :clinicians, through: :clinician_special_cases

   validates :name, presence: true 

   enum age_type: { self: 0, child: 1, both: 2 }

   default_scope { where(deleted_at: nil) }

   scope :with_age_types, ->(age_type) { where(age_type: [age_type, "both"]) }
end
