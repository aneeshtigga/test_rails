FactoryBot.define do
  factory :clinician_availability_status do
    sequence(:clinician_availability_key)
    available_date { Time.now.utc + 2.days }
    status { 1 }
  end
end