# == Schema Information
# Schema version: 20230330105145
#
# Table name: license_keys
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  cbo        :bigint           indexed
#  key        :bigint           not null, indexed
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_license_keys_on_cbo  (cbo)
#  index_license_keys_on_key  (key) UNIQUE
#
FactoryBot.define do
  factory :license_key do
    cbo     { rand(1_000_000) }
    key     { rand(1_000_000) } # was: 999456
    active  { true }
    state   { 'AL' }
  end
end
