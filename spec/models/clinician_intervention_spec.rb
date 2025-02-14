require "rails_helper"

RSpec.describe ClinicianIntervention, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:intervention) }
  end
end
