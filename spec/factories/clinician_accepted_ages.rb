FactoryBot.define do
  factory :clinician_accepted_age do
    clinician_id { 1 }
    min_accepted_age { 1 }
    max_accepted_age { 1 }
  end
end
