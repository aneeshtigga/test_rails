require 'rails_helper'

RSpec.describe ClinicianAcceptedAge, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
  end
end
