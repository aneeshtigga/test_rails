class ClinicianPopulation < ApplicationRecord
  belongs_to :clinician
  belongs_to :population
end
