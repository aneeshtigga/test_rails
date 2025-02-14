require "rails_helper"
  
RSpec.describe ExpertisesSync do
  describe ".import_data" do
    let!(:expertise_mart1) { create(:expertise_mart, focus_area_name: "Depression", is_active: true, load_date: 2.years.ago) }
    let!(:expertise_mart2) { create(:expertise_mart, focus_area_name: "Eating Disorder", is_active: false, load_date: 2.years.ago) }
    let!(:expertise_mart3) { create(:expertise_mart, focus_area_name: "Hoarding", is_active: true, load_date: 2.years.ago) }
    let!(:expertise_mart4) { create(:expertise_mart, focus_area_name: "Sleep Issues", is_active: false, load_date: 2.years.ago) }
    let!(:expertise1) { create(:expertise, name: "Depression") }
    let!(:expertise2) { create(:expertise, name: "Eating Disorder") }
    
    before(:each) do
      ExpertisesSync.import_data
    end

    it "creates new expertise records" do
      expect(Expertise.count).to eq(2)
      expect(Expertise.find_by(name: "Hoarding").active).to eq true
    end

    it "updates existing expertise records" do
      expect(Expertise.find_by(name: "Eating Disorder")).to be_nil
    end

    it "does not create inactive expertise records" do
      expect(Expertise.find_by(name: "Sleep Issues")).to be_nil
    end

    context "when a expertise record is deactived in ExpertiseMart" do
      before(:each) do
        expertise_mart1.update(is_active: false)
        ExpertisesSync.import_data
      end

      it "deactivates the expertise" do
        expect(Expertise.unscoped.find_by(name: "Depression").active).to eq false
      end

      context "when a expertise record is reactivated in ExpertiseMart" do
        it "reactivates the expertise" do
          expertise_mart1.update(is_active: true)
          ExpertisesSync.import_data
          expect(Expertise.find_by(name: "Depression").active).to eq true
        end
      end
    end
  end

end
