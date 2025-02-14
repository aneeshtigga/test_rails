FactoryBot.define do
  factory :responsible_party do
    first_name { "Captain" }
    last_name { "Jane" }
    date_of_birth { "04/01/1995" }
    email { "captain.jane@example.com" }
    gender { "female" }
  end
end
