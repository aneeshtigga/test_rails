FactoryBot.define do
  factory :patient do
    sequence(:first_name) { |n| "TestFirstName#{n}" }
    sequence(:last_name) { |n| "TestLastName#{n}" }
    date_of_birth { Date.today - rand(18..80).years }
    sequence(:email) { |n| "test#{n}@example.com" }
    preferred_name { "Dav" }
    phone_number { "1234567890"}
    referral_source { "Search engine (Google, Bing, etc.)" }
    account_holder_relationship { 1 }
    pronouns { "She/her"}
    about  { "Been through couple of theraphies in the past" }
    search_filter_values { {'zip_codes': "40213", 'type_of_cares': "Adult Psychiatry", 'insurances': "Aetna"} }
    credit_card_on_file_collected { true }
    intake_status { 0 }
    special_case
    account_holder
    gender { "male" }
    gender_identity { 'Male' }
    sequence(:provider_id)
    office_code { 995456 }
    referring_provider_name {"Search engine (Google)"}
    referring_provider_phone_number {"7838478901"}
    amd_pronouns_updated { false }
  end


  trait :with_patient_disorders do
    after(:build) do |patient|
      patient.concerns << build(:concern)
    end
  end
end


