require "rails_helper"

RSpec.describe ClinicianEducationSync do
  describe ".import_data" do
    it "imports the data from clinician_education to education" do
      clinician = create(:clinician)
      create(:clinician_education, npi: clinician.npi)
      Sidekiq::Testing.inline! do
        ClinicianEducationSync.import_data
        expect(Education.count).to be 1
      end
    end

    it "doesn't imports clinician_educations with invalid npi" do
      create(:clinician_education, npi: 123)
      Sidekiq::Testing.inline! do
        ClinicianEducationSync.import_data
        expect(Education.count).to be 0
      end
    end
  end

  describe ".get_uniq_npis" do
    it "responds with list of uniq npis" do
      education = create(:clinician_education)
      create(:clinician_education, universityname: "Fordham University", npi: education.npi)
      expect(ClinicianEducation.count).to be > 1
      expect(ClinicianEducationSync.get_uniq_npis.size).to eq 1
      expect(ClinicianEducationSync.get_uniq_npis).to eq([education.npi])
    end
  end
end
