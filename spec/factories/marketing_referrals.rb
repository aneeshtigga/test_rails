FactoryBot.define do
  factory :marketing_referral do
    display_marketing_referral { "OBGYN" }
    amd_marketing_referral { "OBGYN" }
    active { true }
  end
end
