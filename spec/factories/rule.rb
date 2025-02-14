FactoryBot.define do
  factory :rule do
    name { "My rule" }
    data_type { "Boolean" }
    key { "enable_credit_card_onfile" }
    value { "true" }
  end
end
