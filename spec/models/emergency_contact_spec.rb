require 'rails_helper'

RSpec.describe EmergencyContact, type: :model do
  describe "associations" do
    it { should belong_to(:patient) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:phone) }
  end
end
