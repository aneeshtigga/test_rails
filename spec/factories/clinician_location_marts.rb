FactoryBot.define do
  factory :clinician_location_mart do
    license_key { 995456 }
    location { "3rd avenue" }
    city { "Atlanta" }
    state { "Florida" }
    apt_suite { "1" }
    zip_code { "30301" }
    is_active { 1 }
    sequence(:facility_id)
    facility_name { "Stockbridge" }
    clinician_id { 1234 }
    create_timestamp { Time.now.utc }
    change_timestamp { Time.now.utc }
    cbo { "149_330" }
  end
end
