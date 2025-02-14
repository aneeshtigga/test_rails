FactoryBot.define do
  factory :insurance do
    name { "Florida Blues" }
    sequence(:mds_carrier_id)
    mds_carrier_name { "Florida Blues" }
    sequence(:amd_carrier_id)
    amd_carrier_name { "Florida Blues" }
    amd_carrier_code {1}
    amd_is_active {true}
    license_key { "995456" }
    is_active { true }
    obie_external_display { true }
    abie_intake_internal_display { false }
    website_display { true }
    enrollment_effective_from { "2021-01-01" }
  end
end
