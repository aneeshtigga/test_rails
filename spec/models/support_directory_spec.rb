require "rails_helper"

RSpec.describe SupportDirectory, type: :model do
  describe "validation" do
    it { should validate_presence_of(:cbo) }
    it { should validate_presence_of(:license_key) }
  end
end
