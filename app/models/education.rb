class Education < ApplicationRecord
  belongs_to :clinician

  validates :university, presence: true
  validates :degree, presence: true 
end 
