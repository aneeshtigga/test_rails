require "rails_helper"

RSpec.describe TypeOfCareApptType, type: :model do
  context "inheritance" do
    it "is expected inherit from Datawarehouse" do
      expect(TypeOfCareApptType).to be < DataWarehouse
    end

    it "is expected to connect to a different database" do
      expect(TypeOfCareApptType.connection_db_config.name).not_to be(TypeOfCare.connection_db_config.name)
    end
  end

  describe "#care_data" do
    it "returns personal data attributes" do
      care = create(:type_of_care_appt_type)
      expect(care.care_data).to include(
        amd_license_key: care.amd_license_key,
        amd_appt_type_uid: care.amd_appt_type_uid,
        in_person_visit: care.in_person_visit,
        virtual_or_video_visit: care.virtual_or_video_visit,
        amd_appointment_type: care.amd_appointment_type,
        type_of_care: care.type_of_care,
        facility_id: care.facility_id,
        cbo: care.cbo
      ) 
    end

    it "returns cbo data as part of care" do 
      care = create(:type_of_care_appt_type)
      expect(care.care_data).to include(cbo: care.cbo)
    end
  end
end
