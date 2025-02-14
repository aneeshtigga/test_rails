require "rails_helper"

RSpec.describe Education, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
  end

  describe "validations" do
    it { should validate_presence_of(:degree) }
    it { should validate_presence_of(:university) }
  end
end
