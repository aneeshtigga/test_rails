FactoryBot.define do
  factory :concern_mart do
    focus_area_name {'Eating concerns'}
    focus_area_type {'concern'}
    is_active {1}
    load_date {Time.now.utc}
  end
end