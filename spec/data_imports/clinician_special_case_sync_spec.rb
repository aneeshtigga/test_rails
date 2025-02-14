require "rails_helper"

RSpec.describe ClinicianSpecialCaseSync do
  before do
    create(:license_type, name: "MD")
    create(:license_type, name: "MS")
    create(:expertise, name: "Depression")
    create(:expertise, name: "Eating Disorder")
    create(:language, name: "English")
    create(:language, name: "Spanish")
  end

  describe ".import_data" do
    it "creates clinician special case from clinician mart" do
      clinician_mart = create(:clinician_mart)
      create(:special_case, name: "Recently discharged from a psychiatric hospital")
      Sidekiq::Testing.inline! do
        ClinicianUpdaterWorker.perform_async(clinician_mart.clinician_id, clinician_mart.license_key)
        special_case_count_before = Clinician.first.special_cases.count
        ClinicianSpecialCaseSync.import_data
        expect(Clinician.first.special_cases.count).to be > special_case_count_before
      end
    end
  end

  describe ".update_special_cases" do
    it "associates passed special_cases to the passed clinician_id" do
      clinician_mart = create(:clinician_mart)
      create(:special_case, name: "Recently discharged from a psychiatric hospital")
      Sidekiq::Testing.inline! do
        ClinicianUpdaterWorker.perform_async(clinician_mart.clinician_id, clinician_mart.license_key)
        special_case_count_before = Clinician.first.special_cases.count
        special_cases = ClinicianSpecialCaseSync.get_lfs_special_cases(clinician_mart)

        ClinicianSpecialCaseSync.update_special_cases(Clinician.first.id, special_cases)
        expect(Clinician.first.special_cases.count).to be > special_case_count_before
      end
    end
  end

  describe ".map_lfs_special_cases" do
    it "returns the associated lfs special_case value mapped to mdstaff value" do
      lfs_special_cases = ClinicianSpecialCaseSync.map_lfs_special_cases
      expect(lfs_special_cases["Recently discharged from a psychiatric hospital"]).to eq("Recently discharged from a psychiatric hospital")
      expect(lfs_special_cases["Current Legal Matter"]).to eq("Current legal matter")
    end
  end
end
