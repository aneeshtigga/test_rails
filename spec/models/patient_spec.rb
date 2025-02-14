require 'rails_helper'

RSpec.describe Patient, type: :model do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )

    GenderIdentity.delete_all
    FactoryBot.create(:gender_identity, :male)
    FactoryBot.create(:gender_identity, :female)
    FactoryBot.create(:gender_identity, :neither)
  end

  let(:account_holder) { create(:account_holder) }
  let!(:hipaa_relationship) { HipaaRelationshipCode.create(code: 18, description: "self") }
  let!(:clinician) { create(:clinician, provider_id: 123) }
  let!(:clinician_address) { create(:clinician_address, clinician: clinician, provider_id: clinician.provider_id, office_key: 995456) }
  let!(:clinician_availability) {
    create(:clinician_availability, provider_id: clinician.provider_id, profile_id: 1, column_id: 1, facility_id: clinician_address.facility_id)
  }


  describe "associations" do
    it { should belong_to(:special_case).optional }
    it { should belong_to(:account_holder) }
    it { should have_many(:patient_disorders) }
    it { should have_many(:concerns) }
    it { should have_one(:intake_address) }
    it { should have_many(:insurance_coverages) }
    it { should have_many(:policy_holders) }
    it { should have_many(:patient_appointments) }
    it { should have_many(:clinicians) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:account_holder_relationship) }
    it { should allow_value("Captain Blackbeard").for(:preferred_name) }
    it { should allow_value("").for(:preferred_name) }
    it { should_not allow_value("C@pt@1n Bl@ckbeard").for(:preferred_name) }
    it { should allow_value(nil).for(:preferred_name) }
  end

  describe "callbacks" do
    describe "#create_amd_patient" do
      context "when amd patient does not exist in amd" do
        it "amd_patient_id is set for patient" do
          VCR.use_cassette("add_amd_patient_before_patient_creation") do
            patient = create(:patient, first_name: "Captain", last_name: "Blackbeard", gender: "M", date_of_birth: Time.now - 55.years,
                                       account_holder: account_holder, office_code: 995456, provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code })

            expect { patient.create_amd_patient }.to change { patient.amd_patient_id }.from(nil).to(5983985)
          end
        end

        it "amd_updated_at is set for created patient" do
          VCR.use_cassette("add_amd_patient_before_patient_creation") do
            patient = create(:patient, first_name: "Captain", last_name: "Blackbeard", gender: "M", date_of_birth: Time.now - 55.years,
                                       account_holder: account_holder, office_code: 995456, provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code })
            patient.create_amd_patient

            expect(patient.amd_updated_at).to be_present
          end
        end

        it "adding patient with multiple responsable parties" do
          VCR.use_cassette("add_amd_patient_before_patient_creation_multiple") do
            patient = create(:patient, first_name: "Captain", last_name: "Blackbeard", gender: "M", date_of_birth: Time.now - 55.years,
                                       account_holder: account_holder, office_code: 995456, provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code })
            patient.create_amd_patient

            expect(patient.amd_updated_at).to be_present
          end
        end

        it "creates a responsible party record for patient account holder if patient is self" do
          VCR.use_cassette("add_amd_patient_before_patient_creation_with_lookup") do
            account_holder = create(:account_holder)
            patient = create(:patient, first_name: "Captain", last_name: "Blackbeard", gender: "M", date_of_birth: Time.now - 55.years,
                                       account_holder: account_holder, office_code: 995456, provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code }, account_holder_relationship: :self)
            patient.create_amd_patient

            expect(account_holder.responsible_party).to be_present
            expect(account_holder.responsible_party.amd_updated_at).to be_present
          end
        end

        it "does not create a responsible party for patient account holder if patient is child" do
          VCR.use_cassette("add_amd_patient_before_patient_creation") do
            account_holder = create(:account_holder)
            patient = create(:patient, first_name: "Captain", last_name: "Blackbeard", gender: "M", date_of_birth: Time.now - 55.years,
                                       account_holder: account_holder, office_code: 995456, provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code }, account_holder_relationship: :child)
            patient.create_amd_patient

            expect(account_holder.responsible_party).to eq(nil)
          end
        end
      end

      context "when patient exists in amd" do
        it "amd_patient_id is set for created patient" do
          VCR.use_cassette("get_existing_amd_patient_id_before_patient_creation") do
            account_holder = build(:account_holder, email: "testing@email.com")
            patient = Patient.new(first_name: "Captain", last_name: "Blackbeard", date_of_birth: Date.new(1990, 07, 15), account_holder: account_holder,
                                  gender: "male", office_code: 995456)

            expect(patient.valid?).to be_falsy
            expect(patient.exists_in_amd).to be_truthy
            expect(patient.amd_patient_id).to_not be_nil
            expect(patient.errors[:base].first).to eq("Patient already exists in AMD")
          end
        end
      end
    end

    describe "#set_office_code" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }

      context "setting office_code using the lookup_office_key private method" do
        let!(:address) { create(:clinician_address, office_key: 995456) }

        it "office code is set when clinician address id is present in search_filter_values" do
          patient = Patient.new(first_name: "Captain", last_name: "Blackbeard", date_of_birth: Date.new(1990, 07, 15), account_holder: account_holder, gender: "M",
                                search_filter_values: { clinician_address_id: address.id }, provider_id: 1)

          patient.save

          expect(patient.reload.office_code).to eq(clinician_address.office_key)
        end
      end

      context "office_code is not set when clinician address was not found" do
        it "office code is set using default_office_key" do
          patient = Patient.new(first_name: "Captain", last_name: "Blackbeard", date_of_birth: Date.new(1990, 07, 15), account_holder: account_holder, gender: "M",
                                search_filter_values: { clinician_address_id: 1234 })

          patient.save

          expect(patient.reload.office_code).to eq(nil)
        end
      end

      context "when search_filter_values does not contain the zip_codes key" do
        it "office code is not set when zip_code is not present in search_filter_values" do
          patient = Patient.new(first_name: "Captain", last_name: "Blackbeard", date_of_birth: Date.new(1990, 07, 15), account_holder: account_holder, gender: "M",
                                search_filter_values: {})

          patient.save

          expect(patient.reload.office_code).to be_nil
        end
      end

      context "when clinician address office_key is not include in Rails.application.credentials.amd[:office_keys]" do
        let!(:address) { create(:clinician_address, office_key: 995456) }

        it "office code is set using default_office_key" do
          patient = Patient.new(first_name: "Captain", last_name: "Blackbeard", date_of_birth: Date.new(1990, 07, 15), account_holder: account_holder, gender: "M",
                                search_filter_values: { zip_codes: address.postal_code, clinician_address_id: address.id }, provider_id: 1)

          patient.save

          expect(patient.reload.office_code).to eq(Rails.application.credentials.amd[:default_office_key])
        end
      end
    end

    describe "#sanitize_date_of_birth" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }

      it "date_of_birth format MM/DD/YYYY is accepted" do
        patient = Patient.create(first_name: "Captain", last_name: "Blackbeard", gender: "M", date_of_birth: "10/22/1989", account_holder: account_holder,
                                 office_code: 995456, provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code })

        expect(patient.date_of_birth.to_date.class).to eq(Date)
        expect(patient.date_of_birth).to eq("1989-10-22")
      end
    end

    describe "#policy_holder_mapping" do
      let(:account_holder_relationship) { "self" }
      let(:account_holder) { build(:account_holder) }
      let(:patient) do
        build(:patient,
              account_holder: account_holder,
              account_holder_relationship: account_holder_relationship)
      end

      context "account holder relationship is self" do
        context "primary holder is self" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("self")).to include(
              relationship: "1",
              hipaarelationship: "18"
            )
          end
        end

        context "primary holder is spouse" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("spouse")).to include(
              relationship: "2",
              hipaarelationship: "01"
            )
          end
        end

        context "primary holder is child" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("child")).to include(
              relationship: "3",
              hipaarelationship: "19"
            )
          end
        end

        context "primary holder is other" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("other")).to include(
              relationship: "4",
              hipaarelationship: "G8"
            )
          end
        end
      end

      context "account holder relatioship is patient" do
        let!(:account_holder_relationship) { "child" }

        context "primary holder is self" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("self")).to include(
              relationship: "3",
              hipaarelationship: "19"
            )
          end
        end

        context "primary holder is spouse" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("spouse")).to include(
              relationship: "2",
              hipaarelationship: "01"
            )
          end
        end

        context "primary holder is child" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("child")).to include(
              relationship: "1",
              hipaarelationship: "18"
            )
          end
        end

        context "primary holder is other" do
          it "returns the correct relationship code" do
            expect(patient.policy_holder_mapping("other")).to include(
              relationship: "4",
              hipaarelationship: "G8"
            )
          end
        end
      end
    end

    describe ".hipaa_relationship_codes method" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }

      it "returns hipaa_relationship code" do
        hipaa_relationship_code = create(:hipaa_relationship_code, description: "Self")
        patient = create(:patient)
        expect(patient.hipaa_relationship_codes('self')).to eq(hipaa_relationship_code.code)
      end
    end

    describe ".relation_type_code method" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }

      it "returns relation_type_code value" do
        patient = create(:patient, account_holder_relationship: "self")
        expect(patient.relation_type_code).to eq(1)
      end
    end

    describe ".relationship_types method" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }

      it "returns relationship_types value" do
        hash = { self: 1, spouse: 2, child: 3, other: 4 }.with_indifferent_access
        patient = create(:patient, account_holder_relationship: "self")
        expect(patient.relationship_types).to eq(hash)
      end
    end

    describe "#patient_state" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }

      context "Clinician address id in search filter values hash is present" do
        it "returns the state that patient is booked for" do
          postal_code = create(:postal_code, zip_code: "02151", state: "MA")
          clinician_address = create(:clinician_address, postal_code: "02151")
          patient = create(:patient, account_holder_relationship: "self", search_filter_values: { clinician_address_id: clinician_address.id })

          expect(patient.patient_state).to eq("MA")
        end
      end

      context "Clinician address id in search filters values hash is nil" do
        it "returns nil" do
          postal_code = create(:postal_code, zip_code: "02151", state: "MA")
          clinician_address = create(:clinician_address, postal_code: "02151")
          patient = create(:patient, account_holder_relationship: "self", search_filter_values: {})

          expect(patient.patient_state).to eq(nil)
        end
      end
    end

    describe "#callbacks on different cbo" do
      before :all do 
        LicenseKey.find_or_create_by(
          key:    996075,
          cbo:    149331,
          active: true
        )
      end
  
      let!(:address) { create(:clinician_address, office_key: 996075, cbo: 149331) }
      let!(:availability) { create(:clinician_availability, provider_id: address.provider_id, facility_id: address.facility_id) }

      context "#create_amd_patient" do
        it "creates patient on AMD using different CBO" do
          VCR.use_cassette("amd/cbo/creat_amd_patient_success") do
            patient = create(:patient, first_name: "Brady", last_name: "Lee", office_code: nil, date_of_birth: "04/01/1996",
                                       search_filter_values: { clinician_address_id: address.id }, provider_id: 1)

            patient.create_amd_patient

            expect(patient.amd_patient_id).to_not be_nil
            expect(patient.office_code).to eq(address.office_key)
          end
        end
      end

      context "#post_marketing_referral" do
        it "creates patient on AMD using different CBO" do
          skip_referral_amd_creation

          Sidekiq::Testing.inline! do
            patient = create(:patient, first_name: "Brad", last_name: "Lee", office_code: nil, date_of_birth: "04/01/1996",
                                        referral_source: "Hospital", search_filter_values: { clinician_address_id: address.id }, provider_id: 1, amd_patient_id: 123)
            patient.post_marketing_referral

            expect(patient.reload.marketing_referral_id).to be_an(Integer)
          end
        end
      end
    end
  end

  context "with amd credit card setup" do
    let!(:patient) {
      skip_patient_amd_creation
      amd_client = double("AmdClient")
      amd_transaction = double("TransactionsApi")
      amd_client.stub(:transactions).and_return(amd_transaction)
      allow_any_instance_of(Patient).to receive(:client).and_return(amd_client)
      allow(amd_transaction).to receive(:credit_card_on_file?).and_return(false)
      allow(amd_transaction).to receive(:add_credit_card).with(anything).and_return(false)

      create(:patient, first_name: "Captain", last_name: "Blackbeard", gender: "M", date_of_birth: Time.now - 55.years,
        account_holder: account_holder, office_code: 995456, provider_id: 123, search_filter_values: { zip_codes: clinician_address.postal_code })
    }
  
    describe "#amd_has_ccof?" do
      it "returns a boolean" do
        expect(patient.amd_has_ccof?).to be_falsy
        expect(patient.client.transactions).to have_received(:credit_card_on_file?).with(anything).once
      end
    end

    describe "#amd_save_ccof" do
      it "calls transaction api add_credit_card" do
        expect(patient.amd_save_ccof({"creditCardToken" => "mytoken"})).to be_falsy
        expect(patient.client.transactions).to have_received(:add_credit_card).with(anything).once
      end
    end
  end

  describe "#display_name" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }

    context "when patient has a preferred name" do
      it "returns the preferred name" do
        patient = Patient.create(
          first_name: "John",
          last_name: "Blackbeard",
          preferred_name: "Johnny",
          gender: "M",
          date_of_birth: "10/22/1989",
          account_holder: account_holder,
          office_code: 995456,
          provider_id: 123,
          search_filter_values: { zip_codes: clinician_address.postal_code }
        )

        expect(patient.display_name).to eq("Johnny")
      end
    end

    context "when patient has no preferred name" do
      it "returns the first name" do
        patient = Patient.create(
          first_name: "John",
          last_name: "Blackbeard",
          gender: "M",
          date_of_birth: "10/22/1989",
          account_holder: account_holder,
          office_code: 995456,
          provider_id: 123,
          search_filter_values: { zip_codes: clinician_address.postal_code }
        )

        expect(patient.display_name).to eq("John")
      end
    end

    context "when patient has an empty preferred name" do
      it "returns the first name" do
        patient = Patient.create(
          first_name: "John",
          last_name: "Blackbeard",
          preferred_name: "",
          gender: "M",
          date_of_birth: "10/22/1989",
          account_holder: account_holder,
          office_code: 995456,
          provider_id: 123,
          search_filter_values: { zip_codes: clinician_address.postal_code }
        )

        expect(patient.display_name).to eq("John")
      end
    end
  end
end
