require "rails_helper"

describe FacilityFilters, type: :class do
  context ".get_locations" do
    let!(:unmatching_address) do
      create(:clinician_address, clinician: create(:clinician), postal_code: "33010", facility_id: 2345,
                                 facility_name: "buggs town")
    end
    let!(:unmatched_care) { create(:type_of_care, facility_id: unmatching_address.facility_id) }

    let!(:matching_address) do
      create(:clinician_address, clinician: create(:clinician), postal_code: "53001", facility_id: 1234,
                                 facility_name: "bunny's street")
    end
    let!(:matching_care) do
      create(:type_of_care, facility_id: matching_address.facility_id,
                            type_of_care: "Adult Theraphy")
    end

    it "returns addresses with matching zipcode" do
      expect(FacilityFilters.get_locations({ zip_code: matching_address.postal_code }).first.facility_name).to eq(matching_address.facility_name)
    end

    it "does not return duplicates" do
      create(:clinician_address, clinician: create(:clinician), postal_code: "53001", facility_id: 1234,
        facility_name: "bunny's street")

      expect(FacilityFilters.get_locations({ zip_code: matching_address.postal_code }).size).to eq(1)
    end

    it "orders records by city, address" do
      create(:clinician_address, clinician: create(:clinician), postal_code: "53001", facility_id: 1,
        facility_name: "Stockton", city: "Boston")
      create(:clinician_address, clinician: create(:clinician), postal_code: "53001", facility_id: 2,
        facility_name: "Stockton 2", city: "Austin", address_line1: "300 storrow")
      create(:clinician_address, clinician: create(:clinician), postal_code: "53001", facility_id: 3,
        facility_name: "Stockton 3", city: "Austin", address_line1: "10 storrow")

      expect(FacilityFilters.get_locations({ zip_code: matching_address.postal_code }).map(&:city)).to match_array(%w[Atlanta Austin Austin Boston])
      expect(FacilityFilters.get_locations({ zip_code: matching_address.postal_code }).map(&:address_line1)).to match_array(["10 storrow", "300 storrow", "3rd avenue", "3rd avenue"])
    end

    it "returns addresses which have requested type of care offered" do
      expect(FacilityFilters.get_locations({ type_of_care: matching_care.type_of_care }).first.facility_name).to eq(matching_address.facility_name)
    end

    it "returns addresses which support requested filters" do
      expect(FacilityFilters.get_locations({ 
        type_of_care: matching_care.type_of_care,
        zip_code: matching_address.postal_code
      }).first.facility_name).to eq(matching_address.facility_name)
    end
  end
end
