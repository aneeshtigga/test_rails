FactoryBot.define do
  factory :type_of_care do
    amd_license_key { 995456 }
    amd_appt_type_uid { 647842 }
    amd_appointment_type { "TELE IA" }
    type_of_care { "Child Neuro/Psych Testing" }
    age_group { "6 +" }
    facility_id { 110 }
    cbo { 149330 }
    clinician
  end
end
