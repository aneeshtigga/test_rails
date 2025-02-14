require 'rails_helper'

RSpec.describe SpecialCase, type: :model do
  describe "associations" do
    it { should have_many(:patients) }
    it { should have_many(:clinician_special_cases) }
    it { should have_many(:clinicians) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  context "scopes" do
    let!(:special_case1) { create(:special_case, age_type: "child") }
    let!(:special_case2) { create(:special_case, age_type: "self") }
    let!(:special_case3) { create(:special_case, age_type: "child", deleted_at: Time.now) }

    describe ".with_age_types" do
      it "filters only special_case age types" do
        expect(SpecialCase.with_age_types("self")).to match_array([special_case2])
      end

      it "does not return soft deleted special_cases" do
        expect(SpecialCase.with_age_types("child")).to match_array([special_case1])
      end
    end
  end
end
