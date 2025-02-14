FactoryBot.define do
  factory :carrier_insurance do
    license_key { 995456 }
    clinician_id  { 32 }
    facility_id   { 40 }
    npi { 1_396_832_002 }
    mds_carrier_id {1}
    mds_carrier_name { "Imagine Health" }
    amd_carrier_id {1}
    amd_carrier_name { "Imagine Health" }
    amd_carrier_code {1}
    amd_is_active {true}
    amd_create_timestamp { Time.now.utc }
    amd_change_timestamp { Time.now.utc }
  end
end
