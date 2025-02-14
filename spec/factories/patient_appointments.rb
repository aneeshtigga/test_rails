FactoryBot.define do
  factory :patient_appointment do
    clinician
    clinician_address
    patient
    appointment
    status { "booked" }
    appointment_note { "sample appointment note" }
    amd_appointment_id { 9543341 }
    license_key { 995456 }
    cbo { 149_330 }
  end
end
