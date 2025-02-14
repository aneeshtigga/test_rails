require "rails_helper"
  
RSpec.describe ConcernsSync do
  describe "#import_data" do
    let!(:concern_mart1) { create(:concern_mart, focus_area_name: "Eating concerns", is_active: true, load_date: 2.years.ago) }
    let!(:concern_mart2) { create(:concern_mart, focus_area_name: "Drug concerns", is_active: false, load_date: 2.years.ago) }
    let!(:concern_mart3) { create(:concern_mart, focus_area_name: "Test concerns", is_active: true, load_date: 2.years.ago) }
    let!(:concern_mart4) { create(:concern_mart, focus_area_name: "AI concerns", is_active: false, load_date: 2.years.ago) }

    let!(:concern1) { create(:concern, name: "Eating concerns") }
    let!(:concern2) { create(:concern, name: "Drug concerns") }
        
    it "creates new concern records but throws RogueConcernException" do
      expect { ConcernsSync.import_data }.to raise_error(RogueConcernException)

      expect(Concern.count).to eq(1)
      expect(Concern.find_by(name: "Eating concerns").active).to eq true
      expect(Concern.unscoped.find_by(name: "Test concerns").active).to eq false
    end

    it "updates existing concern records" do
      expect { ConcernsSync.import_data }.to raise_error(RogueConcernException)

      expect(Concern.find_by(name: "Drug concerns")).to be_nil
    end

    it "does not create inactive concern records" do
      expect { ConcernsSync.import_data }.to raise_error(RogueConcernException)

      expect(Concern.find_by(name: "AI concerns")).to be_nil
    end

    context "when a concern record is deactived in ConcernMart" do
      before(:each) do
        concern_mart1.update(is_active: false)
        expect { ConcernsSync.import_data }.to raise_error(RogueConcernException)
      end

      it "deactivates the concern" do
        expect(Concern.unscoped.find_by(name: "Eating concerns").active).to eq false
      end
    end
  end
end