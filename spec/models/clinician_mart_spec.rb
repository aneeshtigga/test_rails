require "rails_helper"

RSpec.describe ClinicianMart, type: :model do
  let(:subject) { FactoryBot.build(:clinician_mart) }

  describe ".active" do
    let(:active_clinician_mart) { create(:clinician_mart, is_active: 1) }

    it "returns only active ClinicianMarts" do
      expect(ClinicianMart.active).to match([active_clinician_mart])
    end
  end

  describe "#personal_info" do
    it "returns personal data attributes" do
      expect(subject.personal_info).to include(
        about_the_provider: "about me",
        ages_accepted: "3-18",
        clinician_type: "PSYCHIATRIST",
        first_name: "Captain",
        gender: "male",
        in_office: true,
        last_name: "Jack",
        license_type: "MD",
        manages_medication: true,
        npi: subject.npi,
        pronouns: "He",
        provider_id: subject.clinician_id,
        telehealth_url: "http://www.example.com/video",
        video_visit: true
      )
    end
  end

  describe "#location_info" do
    it "returns location data attributes" do
      expect(subject.location_info).to include(
        address_line1: "4260 Palm Ave ",
        city: "San Diego",
        postal_code: "45645-8764",
        facility_id: 1,
        facility_name: "STOCKBRIDGE",
        state: "CA",
        primary_location: true,
        apt_suite: "BLDG 8 STE 330"
      )
    end
  end
end
