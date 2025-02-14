FactoryBot.define do
  factory :account_holder do
    sequence(:first_name) { |n| "TestFirstName#{n}" }
    sequence(:last_name) { |n| "TestLastName#{n}" }
    date_of_birth { Date.today - rand(18..80).years }
    sequence(:email) { |n| "test#{n}@example.com" }
    confirmation_email { "confirmation@email.com" }
    gender { "male" }
    gender_identity { "Male" }
    phone_number { "+917937452124" }
    source { "Search engine (Google, Bing, etc.)" }
    email_verification_sent {false}
    receive_email_updates {false}
    pronouns { "She/Her"}
    about  { "Been through couple of theraphies in the past" }
    search_filter_values { {zip_codes: "40213", type_of_cares: "Adult Psychiatry", payment_type: "insurance"} }
    selected_slot_info {{reservation: {modality: "VIDEO"}, preferences: {marketingReferralPhone: ''}}}
  end

  trait :with_intake_address do
    after(:build) do |account_holder|
      account_holder.intake_addresses << build(:intake_address)
    end
  end
end
