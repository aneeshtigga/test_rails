require "rails_helper"

RSpec.describe ClinicianLanguage, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:language) }
  end
end
