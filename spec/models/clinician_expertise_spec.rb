require "rails_helper"

RSpec.describe ClinicianExpertise, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:expertise) }
  end
end
