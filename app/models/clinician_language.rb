class ClinicianLanguage < ApplicationRecord
  belongs_to :clinician
  belongs_to :language
end
