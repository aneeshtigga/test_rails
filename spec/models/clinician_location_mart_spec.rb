require "rails_helper"

RSpec.describe ClinicianLocationMart, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  context ".scopes" do
    describe ".with_provider_id" do
      it "Filters the ClinicianLocations by means of clinician id" do
        unmatched_location = create(:clinician_location_mart)
        matched_location = create(:clinician_location_mart, clinician_id: 1234)

        expect(ClinicianLocationMart.with_clinician_id(1234)).to include(matched_location)
      end
    end

    describe ".with_valid_location" do
      it "filters clinician_locations with valid clinician and location values" do
        unmatched_location = create(:clinician_location_mart, clinician_id: nil, location: nil)
        matched_location = create(:clinician_location_mart)

        expect(ClinicianLocationMart.with_valid_location).to include(matched_location)
      end
    end
  end

  describe "#location_info" do
    it "returns the sliced object with appropriate data mapping" do
      clinician_location = create(:clinician_location_mart)

      expect(clinician_location.location_info).to eq({ address_line1: clinician_location.location,
                                                       apt_suite: clinician_location.apt_suite,
                                                       area_code: clinician_location.area_code,
                                                       city: clinician_location.city,
                                                       country_code: clinician_location.country_code,
                                                       office_key: clinician_location.license_key,
                                                       postal_code: clinician_location.zip_code,
                                                       primary_location: clinician_location.primary_location,
                                                       provider_id: clinician_location.clinician_id,
                                                       state: clinician_location.state,
                                                       facility_id: clinician_location.facility_id,
                                                       facility_name: clinician_location.facility_name,
                                                       deleted_at: nil,
                                                       cbo: clinician_location.cbo })
    end

    it "includes cbo of the clinician_location_mart" do
      clinician_location = create(:clinician_location_mart)

      expect(clinician_location.location_info.keys).to include(:cbo)
    end
  end

  describe "#clinician_location_keys" do
    it "returns the composite keys (facility_id, office_key, provider_id) for given clinician_location_mart" do
      location = create(:clinician_location_mart)

      expect(location.clinician_location_keys).to eq({ facility_id: location.facility_id,
                                                       provider_id: location.clinician_id,
                                                       office_key: location.license_key,
                                                       cbo: location.cbo
                                                     })
    end
  end

  describe "#deleted_at" do
    it "returns nil for clinician_location_mart when is_active as 1" do
      location = create(:clinician_location_mart, is_active: 1)

      expect(location.deleted_at).to eq(nil)
    end

    it "returns datetime for clinician_location_mart when is_active as 0" do
      freeze_time do
        ts = Time.now.utc
        location = create(:clinician_location_mart, is_active: 0)

        expect(location.deleted_at).to eq(ts)
      end
    end
  end
end
