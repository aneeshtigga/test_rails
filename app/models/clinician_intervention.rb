class ClinicianIntervention < ApplicationRecord
  belongs_to :clinician
  belongs_to :intervention
end
