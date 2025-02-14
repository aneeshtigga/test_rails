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
require "rails_helper"

RSpec.describe LicenseKey, type: :model do
  describe "validation" do
    it { should validate_presence_of(:key) }
  end

  describe "associations" do
    it { should have_many(:license_key_rules) }
  end
end
