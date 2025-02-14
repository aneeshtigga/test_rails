FactoryBot.define do
  factory :clinician_mart do
    first_name { "Captain" }
    middle_name { "Joe" }
    last_name { "Jack" }
    clinician_type { "PSYCHIATRIST" }
    license_type { "MD" }
    expertise { "Depression, Eating Disorder" }
    about_the_provider { "about me" }
    in_office { true }
    virtual_visit { true }
    manages_medication { true }
    ages_accepted { "3-18" }
    sequence(:clinician_id)
    sequence(:npi)
    license_key { "995456" }
    primary_location { true }
    location { "4260 Palm Ave " }
    zip_code { "45645-8764" }
    city { "San Diego" }
    state { "CA" }
    area_code { "273" }
    country_code { "USA" }
    cbo { "149_330" }
    telehealth_url { "http://www.example.com/video" }
    gender { "male" }
    languages { "English, Spanish" }
    pronouns { "He" }
    photo { nil }
    facility_name { "STOCKBRIDGE" }
    facility_id { 1 }
    apt_suite { "BLDG 8 STE 330" }
    create_timestamp { Time.now.utc }
    change_timestamp { Time.now.utc }
    load_date {Time.now.utc}
    is_active { 1 }
    special_cases do
      "Recently discharged from a psychiatric hospital, Court Ordered Treatment, Workers Compensation, Disability Paperwork"
    end

    trait :inactive do
      is_active { 0 }
    end
  end
end
