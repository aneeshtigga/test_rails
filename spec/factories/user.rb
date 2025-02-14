FactoryBot.define do
  factory :user do
    first_name { "Jane" }
    last_name { "Smith" }
    email { "test@gmail.com" }
    saml_uid { nil }
  end

end
