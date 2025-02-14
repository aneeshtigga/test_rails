FactoryBot.define do
  factory :clinician_availability do
    sequence(:clinician_availability_key)
    license_key { "995456" }
    sequence(:profile_id)
    sequence(:column_id)
    provider_id { 1 }
    sequence(:npi)
    facility_id { 1 }
    available_date { Time.now.utc + 2.hours + 4.days }
    reason { "IA - TELE" }
    appointment_start_time { Time.now.utc + 2.hours + 4.days }
    appointment_end_time { Time.now.utc + 3.hours + 4.days}
    type_of_care { "Child Neuro/Psych Testing" }
    tele_color { "ORANGE" }
    in_person_color { "BLUE" }
    virtual_or_video_visit { 1 }
    in_person_visit { 1 }
    rank_most_available { 1 }
    rank_soonest_available { 1 }
  end
end
