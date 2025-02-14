FactoryBot.define do
  factory :clinician do
    first_name { "Captain" }
    last_name { "Jack" }
    clinician_type { "Adult Therapy" }
    license_type { "MD" }
    about_the_provider { "about me" }
    in_office { true }
    video_visit { true }
    manages_medication { false }
    ages_accepted { "0-200" }
    sequence(:npi)
    sequence(:provider_id)
    telehealth_url { "http://example.com/hi" }
    gender { "male" }
    pronouns { "His/He/Him" }
    license_key { 995_456 }
    cbo { "149_330" }
    supervised_clinician { false }
    supervisory_disclosure { "" }
    supervisory_type { "" }
    supervising_clinician { "" }
    display_supervised_msg { false }
  end

  trait :active do
    deleted_at { nil }
  end

  trait :inactive do
    deleted_at { Time.zone.now }
  end

  trait :with_address do
    after(:build) do |clinician|
      clinician.clinician_addresses << build(:clinician_address, :with_clinician_availability)
    end
  end

  trait :existing_patient_address do
    after(:build) do |clinician|
      clinician.clinician_addresses << build(:clinician_address, :existing_patient_clinician_availability)
    end
  end

  trait :with_education do
    after(:build) do |clinician|
      clinician.educations << build(:education)
    end
  end
end
