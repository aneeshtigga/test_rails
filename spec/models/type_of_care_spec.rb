require "rails_helper"

RSpec.describe TypeOfCare, type: :model do
  context "validations" do
    it "is valid with valid attributes" do
      create(:type_of_care)
      expect(TypeOfCare.first).to be_valid
    end
  end

  context "default values" do
    it "will have in person visit field set default to false" do
      type_of_care = create(:type_of_care)
      expect(type_of_care.in_person_visit).to be false
    end

    it "will have virtual or video visit field set default to false" do
      type_of_care = create(:type_of_care)
      expect(type_of_care.virtual_or_video_visit).to be false
    end

    it { should validate_presence_of(:type_of_care) }
    it { should validate_presence_of(:amd_appt_type_uid) }
    it { should validate_presence_of(:amd_license_key) }
    it { should validate_presence_of(:facility_id) }
  end

  describe ".import data" 
    context "import data from dataware house" do
      let!(:clinician) { create(:clinician) }
      let!(:type_of_care_appt_type) do
        create(:type_of_care_appt_type, clinician_id: clinician.provider_id, amd_license_key: clinician.license_key, cbo: 130000 )
      end

      it "is expected that imported data to be in sync" do
        Sidekiq::Testing.inline! do
          TypeOfCare.import_data
        end
        type_of_care = TypeOfCare.first.slice(:amd_license_key, :type_of_care)
        type_of_care_appt_type = TypeOfCareApptType.find_by(clinician_id: clinician.provider_id)
        type_of_care_appt_type_keys = type_of_care_appt_type.slice(:amd_license_key, :type_of_care)
        
        expect(type_of_care).to eq(type_of_care_appt_type_keys)
        expect(clinician.provider_id).to eq(type_of_care_appt_type.clinician_id)
      end

      it "is expected to insert records from dataware house" do
        Sidekiq::Testing.inline! do
          TypeOfCare.import_data
        end

        expect(TypeOfCare.count).to eq(1) 
      end

      it "will import all TypeOfCareApptType records to TypeOfCare" do
        type_of_care_appt_type_count = TypeOfCareApptType.where(clinician_id: clinician.provider_id).count
        Sidekiq::Testing.inline! do
          TypeOfCare.import_data
        end

        expect(TypeOfCare.count).to eq(type_of_care_appt_type_count)
      end

      it "will import TypeOfCare data which includes facility_id and clinician_id" do
        type_of_care_appt_type_count = TypeOfCareApptType.where(clinician_id: clinician.provider_id).count
        Sidekiq::Testing.inline! do
          TypeOfCare.import_data
        end
        type_of_care = TypeOfCare.last
        type_of_care_appt_type = TypeOfCareApptType.last

        expect(TypeOfCare.count).to eq(type_of_care_appt_type_count)
        expect(TypeOfCare.column_names).to include("facility_id", "clinician_id")
        expect(type_of_care.slice(:facility_id)).to include(facility_id: type_of_care_appt_type.facility_id)
        expect(type_of_care.clinician.provider_id).to eq(type_of_care_appt_type.clinician_id)
      end

      it "imports cbo data of type_of_care" do
        Sidekiq::Testing.inline! do 
          TypeOfCare.import_data
        end

        expect(TypeOfCare.count).to eq 1
        expect(TypeOfCare.first.cbo).to eq(type_of_care_appt_type.cbo)
      end
    end

    context "scopes" do
      describe ".with_license_keys" do
        it "will filter records with passed type of care" do
          care1 = create(:type_of_care)
          care2 = create(:type_of_care, type_of_care: "Neuro Theraphy")

          expect(TypeOfCare.with_care(care1.type_of_care).count).to eq(1)
          expect(TypeOfCare.with_care(care1.type_of_care).first.id).to eq(care1.id)
        end
      end
    end

  describe "associations" do
    it { should belong_to(:clinician).without_validating_presence }
  end

  describe ".create_data method from TypeOfCare" do
    context "when TypeOfCareApptType.type_of_care is nil" do
      it "does not create a TypeOfCare" do
        clinician = create(:clinician)
        create(:type_of_care_appt_type, clinician_id: clinician.provider_id, amd_license_key: clinician.license_key, type_of_care: nil)

        response = TypeOfCare.create_data([clinician.id])
        expect(response[:type_of_cares_in_dw]).to eq 1
        expect(response[:type_of_cares_synced]).to eq 0
      end
    end

    it "type of care create successfully" do
      clinician = create(:clinician)
      create(:type_of_care_appt_type, clinician_id: clinician.provider_id, amd_license_key: clinician.license_key)
      TypeOfCare.create_data([clinician.id])

      expect(TypeOfCare.all.size).to eq(1)
    end
  end

  context ".get_cares_by_state" do
    it "returns the available type of cares by state" do
      address = create(:clinician_address)
      care = create(:type_of_care,facility_id: address.facility_id, clinician_id: address.clinician_id)
      expect(TypeOfCare.get_cares_by_state(address.state)).to include(care.type_of_care)
    end

    it "returns type_of_cares in sorted order" do
      address = create(:clinician_address)
      care1 = create(:type_of_care,type_of_care:"Child Therapy",facility_id: address.facility_id, clinician_id: address.clinician_id)
      care2 = create(:type_of_care, type_of_care:"Adult Psychiatry",facility_id: address.facility_id, clinician_id: address.clinician_id)
      expect(TypeOfCare.get_cares_by_state(address.state)).to eq(["Adult Psychiatry","Child Therapy"])
    end
  end 

  context ".with_non_testing_cares" do 
    it "should returns the records with testing cares" do 
      address = create(:clinician_address)
      care1 = create(:type_of_care,type_of_care:"Child Therapy",facility_id: address.facility_id, clinician_id: address.clinician_id)
      care2 = create(:type_of_care, type_of_care:"Psych Testing",facility_id: address.facility_id, clinician_id: address.clinician_id)
      expect(TypeOfCare.with_non_testing_cares.count).to be<(TypeOfCare.count)
    end
  end
end
