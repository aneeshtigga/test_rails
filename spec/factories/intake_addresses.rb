FactoryBot.define do
  factory :intake_address do
    address_line1 { "3rd avenue" }
    address_line2 { "Blueflies street" }
    city { "Atlanta" }
    state { "AT" }
    postal_code { "30301" }
  end
end
