FactoryBot.define do
  factory :license_key_rule do
    rule_name { "MyString" }
    active { true }
    license_key_id { 1 }
    ruleable_type { "Rule" }
    ruleable_id {nil}
  end
end
