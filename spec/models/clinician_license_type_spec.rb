require 'rails_helper'

RSpec.describe ClinicianLicenseType, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:license_type) }
  end
end
