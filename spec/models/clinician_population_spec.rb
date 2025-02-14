require "rails_helper"

RSpec.describe ClinicianPopulation, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:population) }
  end
end
