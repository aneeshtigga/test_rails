FactoryBot.define do
  factory :feature_enablement do
    state { "AL" }
    is_obie_active { true }
    is_abie_active { true }
    lifestance_state { true }
  end
end
