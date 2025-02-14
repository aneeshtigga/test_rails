FactoryBot.define do
  factory :expertise_mart do
    focus_area_name { "Anxiety" }
    focus_area_type { "expertise" }
    is_active { 1 }
    load_date { "2021-07-14 14:00:00" }

    trait :inactive do
      is_active { 0 }
    end
  end
end
