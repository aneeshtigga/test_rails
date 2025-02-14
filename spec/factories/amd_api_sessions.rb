FactoryBot.define do
  factory :amd_api_session do
    office_code { "995456" }
    redirect_url { "https://example.com/redirect" }
    token { "secret" }
  end
end
