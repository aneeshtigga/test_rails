require 'rails_helper'

RSpec.describe Rule, type: :model do
  describe "validations" do
    it { should validate_presence_of(:key) }
    it { should validate_presence_of(:value) }
  end

  describe "associations" do
    it { should have_many(:license_key_rules) }
  end
end
