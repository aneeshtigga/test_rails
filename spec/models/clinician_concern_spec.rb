require 'rails_helper'

RSpec.describe ClinicianConcern, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:concern) }
  end
end
