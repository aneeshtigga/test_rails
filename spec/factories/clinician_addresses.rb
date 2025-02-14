# == Schema Information
# Schema version: 20230330105145
#
# Table name: clinician_addresses
#
#  id               :bigint           not null, primary key
#  address_code     :string
#  address_line1    :string           not null
#  address_line2    :string
#  apt_suite        :string
#  area_code        :string
#  cbo              :integer
#  city             :string           not null
#  country_code     :string
#  deleted_at       :datetime         indexed, indexed => [postal_code]
#  facility_name    :string
#  latitude         :float            indexed
#  longitude        :float            indexed
#  office_key       :bigint           indexed => [provider_id, facility_id]
#  postal_code      :string           indexed, indexed => [deleted_at]
#  primary_location :boolean          default(TRUE)
#  state            :string           not null, indexed
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  clinician_id     :bigint           not null, indexed
#  facility_id      :bigint           indexed => [provider_id, office_key]
#  provider_id      :bigint           indexed => [facility_id, office_key]
#
# Indexes
#
#  index_clinician_addresses_on_clinician_id                (clinician_id)
#  index_clinician_addresses_on_deleted_at                  (deleted_at)
#  index_clinician_addresses_on_latitude                    (latitude)
#  index_clinician_addresses_on_longitude                   (longitude)
#  index_clinician_addresses_on_pid_fid_lk                  (provider_id,facility_id,office_key)
#  index_clinician_addresses_on_postal_code                 (postal_code)
#  index_clinician_addresses_on_postal_code_and_deleted_at  (postal_code,deleted_at)
#  index_clinician_addresses_on_state                       (state)
#
# Foreign Keys
#
#  fk_rails_...  (clinician_id => clinicians.id)
#
FactoryBot.define do
  factory :clinician_address do
    address_line1 { "3rd avenue" }
    address_line2 { "Blueflies street" }
    city { "Atlanta" }
    state { "FL" }
    apt_suite { "1" }
    postal_code { "30301" }
    facility_id { 1 }
    facility_name { "Stockbridge" }
    provider_id { 1 }
    office_key { "995456" }
    cbo { "149_330" }
    latitude {33.677903}
    longitude {-84.4030537}
    clinician
  end

  after(:build) { |clinician_address| clinician_address.class.skip_callback(:commit, :after, :update_latitude_longitude, raise: false) }

  trait :with_clinician_availability do
    after(:build) do |clinician_address|
      clinician_address.clinician_availabilities <<
        build(:clinician_availability,
          provider_id: clinician_address.provider_id,
          license_key: clinician_address.office_key)
    end
  end

  trait :existing_patient_clinician_availability do
    after(:build) do |clinician_address|
      clinician_address.clinician_availabilities << build(:clinician_availability, reason: "TELE")
    end
  end
end
