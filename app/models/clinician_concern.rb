class ClinicianConcern < ApplicationRecord
  belongs_to :clinician
  belongs_to :concern
end
