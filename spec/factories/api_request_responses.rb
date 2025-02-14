FactoryBot.define do
  factory :api_request_response do
    payload { '{}' }
    response { '{}' }
    headers { '{}' }
    url { "MyString" }
    time { "2021-07-27 13:05:11" }
  end
end
