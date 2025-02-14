require 'rails_helper'

RSpec.describe ClinicianSpecialCase, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:special_case) }
  end
end
