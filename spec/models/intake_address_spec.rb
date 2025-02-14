require "rails_helper"

RSpec.describe IntakeAddress, type: :model do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  describe "associations" do
    it { should belong_to(:intake_addressable) }
  end

  describe "validations" do
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:postal_code) }
    it { should validate_presence_of(:address_line1) }
  end

  describe ".callbacks" do
    let(:account_holder) { create(:account_holder) }
    let!(:hipaa_relationship) { HipaaRelationshipCode.create(code: 18, description: "Self") }
    let!(:clinician) { create(:clinician, provider_id: 123) }
    let!(:clinician_address) do
      create(:clinician_address, clinician: clinician, provider_id: clinician.provider_id, office_key: 995_456)
    end
    let!(:clinician_availability) do
      create(:clinician_availability, provider_id: clinician.provider_id, profile_id: 1, column_id: 1,
                                      facility_id: clinician_address.facility_id)
    end
    let(:patient) do
      create(:patient, first_name: "test patients", last_name: "intake address", amd_patient_id: 5983942, account_holder_id: account_holder.id,
                       search_filter_values: { zip_codes: clinician_address.postal_code }, account_holder_relationship: "self", provider_id: clinician_address.provider_id)
    end
    let(:intake_address) { create(:intake_address) }

    it "updates patient intake address in AMD" do
      VCR.use_cassette("amd/update_patient_intake_address") do
        patient.intake_address = build(:intake_address)

        expect(patient.intake_address.save!).to be true
      end
    end
  end

  describe ".patient_params" do
    let(:account_holder) { create(:account_holder) }
    let!(:hipaa_relationship) { HipaaRelationshipCode.create(code: 18, description: "Self") }
    let!(:clinician) { create(:clinician, provider_id: 123) }
    let!(:clinician_address) do
      create(:clinician_address, clinician: clinician, provider_id: clinician.provider_id, office_key: 995_456)
    end
    let!(:clinician_availability) do
      create(:clinician_availability, provider_id: clinician.provider_id, profile_id: 1, column_id: 1,
                                      facility_id: clinician_address.facility_id)
    end
    let(:patient) do
      create(:patient, first_name: "test patient1", last_name: "intake address",amd_patient_id: 5983942, account_holder_id: account_holder.id,
                       search_filter_values: { zip_codes: clinician_address.postal_code }, account_holder_relationship: "self", provider_id: clinician_address.provider_id)
    end
    let(:intake_address) { create(:intake_address) }

    it "returns the hash of required properties for AMD patient creation" do
      VCR.use_cassette("amd/update_patient_intake_address") do
        patient.intake_address = build(:intake_address)
        patient.intake_address.save!

        expect(patient.intake_address.send(:patient_params)).to eq({ :@id => 5983942,
                                                                     :address => { :@address2 => "Blueflies street", :@address1 => "3rd avenue", :@city => "Atlanta", :@zip => "30301",
                                                                                   :@state => "AT" } })
      end
    end
  end

  describe ".check_patient" do
    let(:account_holder) { create(:account_holder) }
    let!(:hipaa_relationship) { HipaaRelationshipCode.create(code: 18, description: "Self") }
    let!(:clinician) { create(:clinician, provider_id: 123) }
    let!(:clinician_address) do
      create(:clinician_address, clinician: clinician, provider_id: clinician.provider_id, office_key: 995_456)
    end
    let!(:clinician_availability) do
      create(:clinician_availability, provider_id: clinician.provider_id, profile_id: 1, column_id: 1,
                                      facility_id: clinician_address.facility_id)
    end
    let(:patient) do
      create(:patient, first_name: "test patient2", last_name: "intake address", amd_patient_id: 5983942, account_holder_id: account_holder.id,
                       search_filter_values: { zip_codes: clinician_address.postal_code }, account_holder_relationship: "self", provider_id: clinician_address.provider_id)
    end
    let(:intake_address) { create(:intake_address) }

    it "returns the hash of required properties for AMD patient creation" do
      VCR.use_cassette("amd/update_patient_intake_address") do
        patient.intake_address = build(:intake_address)
        patient.intake_address.save!

        expect(patient.intake_address.send(:check_patient?)).to be(true)
      end
    end
  end


  describe "#callbacks on different cbo" do
    before :all do 
      create(:license_key, 
        key:    996075,
        cbo:    149331,
        active: true
      )
    end

      let!(:address) { create(:clinician_address, office_key: 996075, cbo: 149331) }
      let!(:availability) { create(:clinician_availability, provider_id: address.provider_id, facility_id: address.facility_id)}

      context "#update_patient_address" do
        it "creates patient on AMD using different CBO" do
          VCR.use_cassette("amd/cbo/creat_amd_patient_success") do
            patient = create(:patient, first_name:"Braad", last_name: "Lee", office_code:nil, date_of_birth: "04/01/1996", search_filter_values: { clinician_address_id: address.id }, provider_id: 1)
            VCR.use_cassette("amd/cbo/update_intake_address_success") do
              patient.intake_address = build(:intake_address)
              patient.intake_address.save!
            end
            patient.reload
            expect(patient.intake_address).to_not be_nil
          end
        end
      end
    end
end
