require "rails_helper"

RSpec.describe Expertise, type: :model do
  describe "associations" do
    it { should have_many(:clinician_expertises) }
    it { should have_many(:clinicians) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
