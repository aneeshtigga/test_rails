class Cancellation < ApplicationRecord
  belongs_to :cancellation_reason
  belongs_to :patient_appointment
end
