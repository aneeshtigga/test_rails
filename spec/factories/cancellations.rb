require 'factory_bot'
FactoryBot.define do
  factory :cancellation do
    patient_appointment
    cancellation_reason
    cancelled_by { "Patient" } #Patient or Admin
  end
end
