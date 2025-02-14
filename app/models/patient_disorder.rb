class PatientDisorder < ApplicationRecord
  belongs_to :patient
  belongs_to :concern, required: false
  belongs_to :population, required: false
  belongs_to :intervention, required: false
end
