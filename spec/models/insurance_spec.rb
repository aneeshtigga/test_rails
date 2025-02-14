require "rails_helper"

RSpec.describe Insurance, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "associations" do
    it { should have_many(:facility_accepted_insurances) }
    it { should have_many(:clinician_addresses) }
    it { should have_many(:clinicians) }
  end

  context "scopes" do
    describe ".with_zip_code" do
      it "filters insurances by zip_code" do
        clinician = create(:clinician)
        address = create(:clinician_address, clinician: clinician, postal_code: "53001")
        insurance = create(:insurance)
        create(:facility_accepted_insurance, insurance: insurance, clinician_address: address)

        expect(Insurance.with_zip_codes("53001").first.id).to eq(insurance.id)
      end
    end

    describe ".enabled_for" do
      let!(:insurance1) { create(:insurance) } # obie
      let!(:insurance2) { create(:insurance, abie_intake_internal_display: true, obie_external_display: false) } # abie
      let!(:insurance3) { create(:insurance, abie_intake_internal_display: true) } # both
      let!(:insurance4) { create(:insurance, obie_external_display: false) } # neither

      it "filters insurances by app_name" do
        expect(Insurance.enabled_for("abie").to_a).to eq([insurance2, insurance3])
        expect(Insurance.enabled_for("obie").to_a).to eq([insurance1, insurance3])
      end

      it "throws an error if app_name is not provided" do
        expect { Insurance.enabled_for(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe ".accepted_insurances_by_state" do
    it "filters Insurances by state" do
      clinician = create(:clinician)
      address = create(:clinician_address, clinician: clinician, state: "CA")
      insurance = create(:insurance)
      create(:facility_accepted_insurance, insurance: insurance, clinician_address: address)

      result = Insurance.accepted_insurances_by_state("CA", "obie")
      expect(result.size).to eq 1
      expect(result.first).to eq(insurance.name)
    end

    it "does not show inactive Insurances" do
      clinician = create(:clinician)
      address = create(:clinician_address, clinician: clinician, state: "CA")
      insurance = create(:insurance, is_active: false)
      create(:facility_accepted_insurance, insurance: insurance, clinician_address: address)

      result = Insurance.accepted_insurances_by_state("CA", "obie")
      expect(result.size).to eq 0
    end

    it "returns alphabetically ordered list of uniq accepted insurances" do
      clinician = create(:clinician)
      address = create(:clinician_address, clinician: clinician, state: "CA")
      insurance1 = create(:insurance, name: "Aetna")
      insurance2 = create(:insurance, name: "Cigna")
      create(:facility_accepted_insurance, insurance: insurance1, clinician_address: address)
      create(:facility_accepted_insurance, insurance: insurance2, clinician_address: address)

      result = Insurance.accepted_insurances_by_state("CA", "obie")
      expect(result).to eq(["Aetna", "Cigna"])
    end
  end
end
