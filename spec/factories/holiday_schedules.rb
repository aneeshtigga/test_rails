FactoryBot.define do
  factory :holiday_schedule do
    state { "Alabama" }
    date { "2023-04-28" }
    workday { false }
    description { "Groundhog's day" }
  end
end
