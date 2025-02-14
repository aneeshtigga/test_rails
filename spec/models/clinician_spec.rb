require "rails_helper"

RSpec.describe Clinician, type: :model do
  describe "associations" do
    it { should have_many(:clinician_addresses) }
    it { should have_many(:clinician_languages) }
    it { should have_many(:languages) }
    it { should have_many(:clinician_expertises) }
    it { should have_many(:expertises) }
    it { should have_many(:clinician_license_types) }
    it { should have_many(:license_types) }
    it { should have_many(:insurances) }
    it { should have_many(:type_of_cares) }
    it { should have_many(:facility_accepted_insurances) }
    it { should have_many(:patient_appointments) }
    it { should have_many(:patients) }
    it { should have_many(:clinician_special_cases) }
    it { should have_many(:special_cases) }
    it { should have_many(:educations) }
    it { should have_many(:clinician_accepted_ages) }
    it { should have_many(:concerns) }
    it { should have_many(:clinician_concerns) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:npi) }
    it { should validate_presence_of(:provider_id) }
    it { should validate_presence_of(:license_key) }
  end

  describe ".active" do
    let(:active_clinician) { create(:clinician, :active) }
    let(:inactive_clinician) { create(:clinician, :inactive) }

    it "returns only active clinicians" do
      expect(Clinician.active).to match([active_clinician])
    end
  end

  describe "#soft_delete" do
    let(:clinician) { create(:clinician) }

    it "updates the deleted_at" do
      clinician.soft_delete

      expect(clinician).to be_present
    end

    describe "skipping precense validations" do
      it "updates the deleted_at" do
        clinician.update_columns(clinician_type: nil)
        clinician.reload
        clinician.soft_delete

        expect(clinician).to be_present
        expect(clinician.clinician_type).to be_nil
      end
    end
  end

  describe "#deleted?" do
    describe "clinician is active" do
      let(:clinician) { build(:clinician, :active) }

      it "returns true" do
        expect(clinician.deleted?).to eq(false)
      end
    end

    describe "clinician is inactive" do
      let(:clinician) { build(:clinician, :inactive) }

      it "returns false" do
        expect(clinician.deleted?).to eq(true)
      end
    end
  end

  context "scopes" do
    describe ".with_license_keys" do
      it "filters clinicians by office key" do
        address = create(:clinician_address, clinician: create(:clinician), postal_code: "53001")
        clinician = address.clinician
        expect(Clinician.with_license_keys(address.office_key).first.id).to eq(clinician.id)
      end
    end

    describe ".with_zip_codes" do
      it "filters clinicians by zip code" do
        zip_code = "33010"
        address1 = create(:clinician_address, clinician: create(:clinician), postal_code: "53001")
        address2 = create(:clinician_address, clinician: create(:clinician), postal_code: zip_code)
        clinician = address2.clinician
        expect(Clinician.with_zip_codes(zip_code).first.id).to eq(clinician.id)
      end
    end

    describe ".filter_by_full_name" do
      it "filters clinicians whose firstname or lastname match with searchterm" do
        non_matching_clinician = create(:clinician)
        matching_clinician = create(:clinician, first_name: "David", last_name: "wilson")

        expect(Clinician.filter_by_full_name("david wilson").count).to be < (Clinician.count)
        expect(Clinician.filter_by_full_name("david wilson")).to match_array([matching_clinician])
        expect(Clinician.filter_by_full_name("wilson david")).to match_array([matching_clinician])
        expect(Clinician.filter_by_full_name("david w")).to match_array([matching_clinician])
        expect(Clinician.filter_by_full_name("wilson d")).to match_array([matching_clinician])
      end
    end

    describe ".filter by last name" do
      it "filters clinicians with lastname match with searchterm" do
        non_matching_clinician = create(:clinician)
        matching_clinician = create(:clinician, first_name: "David", last_name: "wilson")
        other_matching_clinician = create(:clinician, first_name: "steph", last_name: "wiliam")

        expect(Clinician.filter_by_last_name("wilson").count).to be < (Clinician.count)
        expect(Clinician.filter_by_last_name("wilson")).to match_array([matching_clinician])
        expect(Clinician.filter_by_last_name("Wil")).to match_array([matching_clinician, other_matching_clinician])
      end
    end

    describe ".filter by first name" do
      it "filters clinicians with firstname match with searchterm" do
        non_matching_clinician = create(:clinician)
        matching_clinician = create(:clinician, first_name: "David", last_name: "wilson")
        other_matching_clinician = create(:clinician, first_name: "Daniel", last_name: "wiliam")

        expect(Clinician.filter_by_first_name("david").count).to be < (Clinician.count)
        expect(Clinician.filter_by_first_name("david")).to match_array([matching_clinician])
        expect(Clinician.filter_by_first_name("da")).to match_array([matching_clinician, other_matching_clinician])
      end
    end

    describe ".with_insurances" do
      it "returns clinicians with insurance name" do
        clinician = create(:clinician)
        address = create(:clinician_address, clinician: clinician)
        insurance = create(:insurance, name: "Health")
        create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)

        clinician_2 = create(:clinician)
        address_2 = create(:clinician_address, clinician: clinician_2)
        insurance_2 = create(:insurance, name: "test")
        create(:facility_accepted_insurance, insurance: insurance_2, clinician_address: address_2)

        expect(Clinician.with_insurances("Health", "obie")).to match_array([clinician])
      end
    end

    describe ".with_accepted_insurances" do
      it "returns clinicians with insurances_accepted" do
        insurance = create(:insurance, name: "Health")

        clinician = create(:clinician)
        address = create(:clinician_address, clinician: clinician)
        create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)

        clinician_2 = create(:clinician)
        address2 = create(:clinician_address, clinician: clinician_2)

        expect(Clinician.with_accepted_insurances).to match_array([clinician])
      end
    end

    describe ".with_accepted_ages" do
      it "returns clinicians with ages in range" do
        clinician = create(:clinician, ages_accepted: "4-12")

        expect(Clinician.with_accepted_ages(4)).to match_array([clinician])
      end

      it "returns no clinicians with ages accepted not in range" do
        create(:clinician, ages_accepted: "4-12")

        expect(Clinician.with_accepted_ages(15)).to be_empty
      end
    end

    describe ".with provider ids" do
      it "filters clinicians by provider id" do
        non_matching_clinician = create(:clinician)
        matching_clinician = create(:clinician, provider_id: 1234)

        expect(Clinician.with_provider_ids(1234).count).to be < Clinician.count
        expect(Clinician.with_provider_ids(1234)).to match_array([matching_clinician])
      end
    end

    describe ".with license type" do
      it "filters clinicians by license type" do
        matching_clinician = create(:clinician, license_type: "MD")
        license_type = create(:license_type, name: "MD")
        create(:clinician_license_type, clinician: matching_clinician, license_type: license_type)
        non_matching_clinician = create(:clinician, license_type: "MS")

        expect(Clinician.with_license_types("MD").count).to be < Clinician.count
        expect(Clinician.with_license_types("MD")).to match_array([matching_clinician])
      end

      it "filters clinicians by license type" do
        matching_clinician_2 = create(:clinician, license_type: "MD")
        matching_clinician_1 = create(:clinician, license_type: "MS")
        license_type1 = create(:license_type, name: "MD")
        create(:clinician_license_type, clinician: matching_clinician_1, license_type: license_type1)
        license_type2 = create(:license_type, name: "MS")
        create(:clinician_license_type, clinician: matching_clinician_2, license_type: license_type2)
        expect(Clinician.with_license_types(["MS", "MD"]).count).to eq Clinician.count
        expect(Clinician.with_license_types(["MS", "MD"])).to match_array([matching_clinician_1, matching_clinician_2])
      end
    end

    describe ".with special_cases" do
      it "filters clinicians by special cases" do
        clinician_1 = create(:clinician)
        clinician_2 = create(:clinician)
        special_case_1 = create(:special_case, name: "Recently discharged from a psychiatric hospital")
        special_case_2 = create(:special_case)
        create(:clinician_special_case, special_case: special_case_1, clinician: clinician_1)
        create(:clinician_special_case, special_case: special_case_2,  clinician: clinician_2)

        expect(Clinician.with_special_cases("Recently discharged from a psychiatric hospital").count).to be < Clinician.count
        expect(Clinician.with_special_cases("Recently discharged from a psychiatric hospital")).to match_array([clinician_1])
      end
    end
  end

  describe ".update_accepted_age_data" do
    it "saves clinicians min and max accepted age" do
      clinician = create(:clinician, ages_accepted: "4-12, 14-64, 65+")
      clinician_accepted_ages = clinician.clinician_accepted_ages
      expect(clinician_accepted_ages.first.min_accepted_age).to eq(4)
      expect(clinician_accepted_ages.first.max_accepted_age).to eq(12)
      expect(clinician_accepted_ages.second.min_accepted_age).to eq(14)
      expect(clinician_accepted_ages.second.max_accepted_age).to eq(64)
      expect(clinician_accepted_ages.last.min_accepted_age).to eq(65)
      expect(clinician_accepted_ages.last.max_accepted_age).to eq(200)
    end
  end

  describe ".presigned_photo" do
    it "returns the presigned_photo from clinician private photo url" do
      photo_url = "https://clinicians-photo.s3.amazonaws.com/5EDDF732-1B75-4BE8-9DA5-4EA5E342F1CD.jpg"
      clinician = create(:clinician,photo: photo_url)
      expect(clinician.presigned_photo).to include(photo_url)
      expect(clinician.presigned_photo).to include("X-Amz-Algorithm")
      expect(clinician.presigned_photo).to include("Signature")
    end

    it "returns nil if clinician doesn't have photo" do
      clinician = create(:clinician,photo: nil)
      expect(clinician.presigned_photo).to eq(nil)
    end
  end


  describe ".with_none_active_address" do
    it "returns clinician with no address" do
      clinician1 = create(:clinician)
      clinician2 = create(:clinician, :with_address)
      clinicians = Clinician.active.with_none_active_address
      expect(clinicians.size).to eq(1)
      expect(clinicians.pluck(:id)).to eq([clinician1.id])
    end
  end

  describe ".mapped_clinician_type" do
    let(:clinician) { build(:clinician, clinician_type: "APN") }
    let(:clinician2) { build(:clinician, clinician_type: "APP") }
    let(:clinician3) { build(:clinician, clinician_type: "Psychiatrist Resident (MD, OD)") }
    let(:clinician4) { build(:clinician, clinician_type: "Psychologist") }
    let(:clinician5) { build(:clinician, clinician_type: "Therapy Associate (MS)") }
    let(:clinician6) { build(:clinician, clinician_type: "Clinical Intern, Unpaid") }
    
    it "return mapped clinician type" do
      expect(clinician.mapped_clinician_type).to eq('Psychiatric Clinician')
      expect(clinician2.mapped_clinician_type).to eq('Psychiatric Clinician')
      expect(clinician3.mapped_clinician_type).to eq('Psychiatric Clinician')
      expect(clinician4.mapped_clinician_type).to eq('Psychotherapist')
      expect(clinician5.mapped_clinician_type).to eq('Psychotherapist')
      expect(clinician6.mapped_clinician_type).to eq('Psychotherapist')
    end
  end

  describe ".duplicates" do
    context "when there are duplicates" do
      let!(:clinician)  { create(:clinician,            provider_id: 123456, npi: 12345, license_key: 123456) }
      let!(:clinician2) { create(:clinician, :inactive, provider_id: 123456, npi: 12345, license_key: 123456) }
      let!(:clinician3) { create(:clinician,            provider_id: 123456, npi: 12345, license_key: 123456) }
      let!(:clinician4) { create(:clinician,            provider_id: 3456,   npi: 12345, license_key: 123456) }
      let!(:clinician5) { create(:clinician,            provider_id: 123456, npi: 12345, license_key: 1234) }
      let!(:clinician6) { create(:clinician,            provider_id: 123456, npi: 12345, license_key: 1234) }

      it "returns duplicates" do
        expect(Clinician.duplicates.to_a.size).to eq(2)
      end

      it "does not return clinicians with a different provider_id" do
        expect(Clinician.duplicates).not_to include(clinician4)
      end

      it "does not return clinicians which have been deleted" do
        expect(Clinician.duplicates).not_to include(clinician2)
      end


      it "removes duplicates from query" do 
        h = Hash.new {|h,k| h[k] = []}

        Clinician.active.each {|r| h[r.unique_ident] << r.id}

        expected_unique_idents =  [
          {cbo: 149330, license_key: 123456,  provider_id: 123456},
          {cbo: 149330, license_key: 123456,  provider_id: 3456},
          {cbo: 149330, license_key: 1234,    provider_id: 123456}
        ]

        expect(h.keys).to eq(expected_unique_idents)

        expect(Clinician.no_duplicates(Clinician.active).count).to eq(3)
      end
    end

    context "when there are no duplicates" do
      let(:clinician)  { create(:clinician, :active,   provider_id: 123456, npi: 12345, license_key: 123456) }
      let(:clinician2) { create(:clinician, :inactive, provider_id: 123456, npi: 12345, license_key: 123456) }
      let(:clinician3) { create(:clinician, :active,   provider_id: 3456,   npi: 12345, license_key: 123456) }

      it "returns empty array" do
        expect(Clinician.duplicates).to eq([])
      end
    end
  end
end
