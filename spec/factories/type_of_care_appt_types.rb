FactoryBot.define do
  factory :type_of_care_appt_type do
    amd_license_key { 9452 }
    amd_appt_type_uid { 647842 }
    amd_appointment_type { "TELE IA" }
    type_of_care { "Child Neuro/Psych Testing" }
    age_group { "6 +" }
    facility_id { 100 }
    cbo { 149330 }
    sequence(:clinician_id)
  end
end
