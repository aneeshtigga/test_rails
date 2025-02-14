require 'rails_helper'

RSpec.describe Concern, type: :model do
  describe "associations" do
    it { should have_many(:clinician_concerns) }
    it { should have_many(:clinicians) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  context "scopes" do
    Concern.unscoped.delete_all
    let(:concern1) { create(:concern, age_type: "child") }
    let(:concern2) { create(:concern, age_type: "self") }
    let(:concern3) { create(:concern, age_type: nil) }

    describe ".with_age_types" do
      it "filters only speciality age types" do
        expect(Concern.with_age_types("self")).to match_array([concern2])
      end
    end

    describe ".has_age_type" do
      it "returns concerns with age_type" do
        expect(Concern.has_age_type).to match_array([concern1, concern2])
      end
    end
  end
end
