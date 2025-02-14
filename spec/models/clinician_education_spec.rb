require "rails_helper"

RSpec.describe ClinicianEducation, type: :model do
  describe ".education_data" do
    it "returns education data" do
      clinician_education = create(:clinician_education)
      expect(clinician_education.education_data).to eq({ university: "Bethel University",
                                                         city: "St. Paul",
                                                         state: "MN",
                                                         country: "United States",
                                                         reference_type: "Medical Education", graduation_year: 2005, degree: "MA" })
    end
  end
end
