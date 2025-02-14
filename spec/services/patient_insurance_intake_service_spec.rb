require "rails_helper"

describe PatientInsuranceIntakeService, type: :class do
  let!(:clinician_address) { create(:clinician_address) }
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:skip_intake_address_amd) { skip_intake_address_amd_creation }

  describe "responsible party is self" do
    let(:first_name) { "Pocoyo" }
    let(:last_name) { "Penguin" }
    let(:date_of_birth) { "01/15/1980" }
    let(:gender) { "female" }
    let(:email) { "email@example.com" }

    let(:responsible_party) do
      create(:responsible_party,
             first_name: first_name,
             last_name: last_name,
             date_of_birth: date_of_birth,
             gender: gender,
             amd_id: "6849971")
    end

    let(:account_holder) do
      create(:account_holder,
             first_name: first_name,
             last_name: last_name,
             date_of_birth: date_of_birth,
             gender: gender,
             email: email,
             responsible_party: responsible_party)
    end

    let(:patient) do
      create(:patient,
             first_name: first_name,
             last_name: last_name,
             date_of_birth: date_of_birth,
             gender: gender,
             account_holder_id: account_holder.id,
             amd_patient_id: "5984282",
             marketing_referral_id: "123")
    end

    let(:intake_address) { create(:intake_address, intake_addressable: patient) }
    let(:insurance_params) do
      {
        "insurance_carrier" => "Aetna",
        "member_id" => "NFC123456",
        "mental_health_phone_number" => "9875551234",
        "primary_policy_holder" => "self"
      }
    end

    let(:intake_service) do
      PatientInsuranceIntakeService.new(patient: patient, insurance_params: insurance_params)
    end

    it "adds an insurance coverage record" do
      VCR.use_cassette("amd/create_insurance_responsible_coverage_success") do
        intake_address
        intake_service.save!

        expect(patient.insurance_coverages.first).to have_attributes(
          company_name: "Aetna",
          member_id: "NFC123456",
          mental_health_phone_number: "9875551234",
          relation_to_policy_holder: "self"
        )
      end
    end

    it "copies over about info from demographic intake" do
      VCR.use_cassette("amd/create_insurance_responsible_coverage_success") do
        intake_address
        intake_service.save!

        expect(patient.insurance_coverages.first.policy_holder).to have_attributes(
          first_name: patient.first_name,
          last_name: patient.last_name,
          date_of_birth: patient.date_of_birth,
          gender: patient.gender
        )
      end
    end

    it "copies over address from address intake" do
      VCR.use_cassette("amd/create_insurance_responsible_coverage_success") do
        intake_address
        intake_service.save!

        responsible_party_address = patient.insurance_coverages.first.policy_holder.intake_address

        expect(responsible_party_address).to have_attributes(
          address_line1: intake_address.address_line1,
          address_line2: intake_address.address_line2,
          city: intake_address.city,
          postal_code: intake_address.postal_code,
          state: intake_address.state
        )
      end
    end

    context "patient does not have address on file" do
      let(:account_holder) { create(:account_holder) }
      let(:patient) { create(:patient, account_holder_id: account_holder.id, intake_address: nil) }
      let(:insurance_params) do
        {
          "insurance_carrier" => "Aetna",
          "member_id" => "NFC123456",
          "mental_health_phone_number" => "9875551234",
          "primary_policy_holder" => "self"
        }
      end

      it "adds an insurance coverage record" do
        VCR.use_cassette("amd/create_insurance_responsible_coverage_success") do
          intake_address
          expect do
            intake_service.save!
          end.to raise_error(StandardError, "Patient address not found. Please update patient address")
        end
      end
    end
  end

  describe "responsible party is spouse, parent/guardian, or child" do
    let(:patient) { create(:patient, amd_patient_id: "5984275", marketing_referral_id: "123") }
    let!(:intake_address) { create(:intake_address, intake_addressable: patient) }
    let(:insurance_params) do
      {
        "insurance_carrier" => "Aetna",
        "member_id" => "NFC123456",
        "mental_health_phone_number" => "9875551234",
        "primary_policy_holder" => "spouse",
        "policy_holder" => {
          "first_name" => "Captain",
          "last_name" => "Jane",
          "date_of_birth" => "01/01/1986",
          "gender" => "female",
          "email" => "test@gmail.com"
        }
      }
    end

    let(:intake_service) do
      PatientInsuranceIntakeService.new(patient: patient, insurance_params: insurance_params)
    end

    it "creates a responsible party record" do
      VCR.use_cassette("create_insurance_responsible_coverage_diff_holder_success") do
        intake_address
        intake_service.save!
        expect(patient.insurance_coverages.first.policy_holder).to have_attributes(
          first_name: "Captain",
          last_name: "Jane",
          date_of_birth: "1986-01-01",
          gender: "female",
          email: "test@gmail.com"
        )
      end
    end

    describe "policy holder has a different address" do
      let(:insurance_params) do
        {
          "insurance_carrier" => "Aetna",
          "member_id" => "NFC123456",
          "mental_health_phone_number" => "9875551234",
          "primary_policy_holder" => "spouse",
          "policy_holder" => {
            "first_name" => "Captain",
            "last_name" => "Jane",
            "date_of_birth" => "01/01/1986",
            "gender" => "female",
            "email" => "test@gmail.com"
          },
          "address" => {
            "address_line1" => "new drive",
            "address_line2" => "2",
            "city" => "Boston",
            "state" => "MA",
            "postal_code" => "02151"
          }
        }
      end

      it "adds policy holder address" do
        VCR.use_cassette("create_insurance_responsible_coverage_diff_holder_success") do
          intake_address
          intake_service.save!
        end

        expect(patient.insurance_coverages.first.policy_holder.intake_address).to have_attributes(
          address_line1: "new drive",
          address_line2: "2",
          city: "Boston",
          state: "MA",
          postal_code: "02151"
        )
      end
    end
  end

  describe "responsible party is child" do
    let!(:address) { create(:clinician_address) }
    let(:insurance) { create(:insurance, amd_carrier_id: 7562) }
    let!(:facility_accepted_insurance) { create(:facility_accepted_insurance, clinician_address: address, insurance: insurance) }
    let(:responsible_party) { create(:responsible_party, amd_id: 6849630) }
    let(:account_holder) { create(:account_holder, responsible_party: responsible_party) }

    let(:patient) { create(:patient, amd_patient_id: 61722, marketing_referral_id: 433, account_holder: account_holder) }
    let!(:intake_address) { create(:intake_address, intake_addressable: patient) }
    let(:insurance_params) do
      {
        "insurance_carrier" => "Aetna",
        "member_id" => "NFC123456",
        "mental_health_phone_number" => "9875551234",
        "primary_policy_holder" => "child"
      }
    end

    let(:intake_service) do
      PatientInsuranceIntakeService.new(patient: patient, insurance_params: insurance_params)
    end

    it "adds an insurance coverage record" do
      VCR.use_cassette("create_insurance_responsible_coverage_diff_holder_success") do
        intake_service.save!
      end

      expect(patient.insurance_coverages.first).to have_attributes(
        company_name: "Aetna",
        member_id: "NFC123456",
        mental_health_phone_number: "9875551234",
        relation_to_policy_holder: "child"
      )
    end

    it "copies over about info from demographic intake" do
      VCR.use_cassette("create_insurance_responsible_coverage_diff_holder_success") do
        intake_service.save!
      end

      expect(patient.insurance_coverages.first.policy_holder).to have_attributes(
        first_name: patient.first_name,
        last_name: patient.last_name,
        date_of_birth: patient.date_of_birth,
        gender: patient.gender,
        email: patient.account_holder.email
      )
    end

    it "copies over address from address intake" do
      VCR.use_cassette("create_insurance_responsible_coverage_diff_holder_success") do
        intake_service.save!
      end
      responsible_party_address = patient.insurance_coverages.first.policy_holder.intake_address

      expect(responsible_party_address).to have_attributes(
        address_line1: intake_address.address_line1,
        address_line2: intake_address.address_line2,
        city: intake_address.city,
        postal_code: intake_address.postal_code,
        state: intake_address.state
      )
    end
  end

  describe "invalid insurance params" do
    let(:patient) { create(:patient, amd_patient_id: "5984275", marketing_referral_id: "123") }
    let!(:intake_address) { create(:intake_address, intake_addressable: patient) }
    let(:insurance_params) do
      {
        "member_id" => "NFC123456",
        "mental_health_phone_number" => "9875551234",
        "primary_policy_holder" => "child"
      }
    end

    let(:intake_service) do
      PatientInsuranceIntakeService.new(patient: patient, insurance_params: insurance_params)
    end

    it "raises an error when missing required params" do
      VCR.use_cassette("create_insurance_responsible_coverage_failure") do
        expect { intake_service.save! }.to raise_error(/Validation failed: Company name can't be blank/)
      end
    end
  end

  describe "updating an existing insurance coverage" do
    let(:first_name) { "Pocoyo" }
    let(:last_name) { "Penguin" }
    let(:date_of_birth) { "01/15/1980" }
    let(:gender) { "female" }
    let(:email) { "email@example.com" }

    let!(:address) { create(:clinician_address) }
    let(:insurance) { create(:insurance, name: "Aetna", amd_carrier_id: 7562) }
    let!(:facility_accepted_insurance) { create(:facility_accepted_insurance, clinician_address: address, insurance: insurance) }

    let(:responsible_party) do
      create(:responsible_party,
             first_name: first_name,
             last_name: last_name,
             date_of_birth: date_of_birth,
             gender: gender,
             amd_id: "6849971")
    end

    let(:account_holder) do
      create(:account_holder,
             first_name: first_name,
             last_name: last_name,
             date_of_birth: date_of_birth,
             gender: gender,
             email: email,
             responsible_party: responsible_party)
    end

    let(:patient) do
      create(:patient,
             first_name: first_name,
             last_name: last_name,
             date_of_birth: date_of_birth,
             gender: gender,
             account_holder_id: account_holder.id,
             amd_patient_id: "5984282",
             marketing_referral_id: "123")
    end

    let(:patient1) do
      create(:patient,
             first_name: "Pocoyo",
             last_name: "patient_last_name",
             date_of_birth: "01/08/1995",
             gender: gender,
             account_holder_id: account_holder.id,
             amd_patient_id: "5984282",
             marketing_referral_id: "123")
    end

    let(:intake_address) { create(:intake_address, intake_addressable: patient) }
    let(:insurance_params) do
      {
        "insurance_carrier" => "Aetna",
        "member_id" => "NFC123456",
        "mental_health_phone_number" => "9875551234",
        "primary_policy_holder" => "spouse",
        "provider_id" => address.provider_id,
        "license_key" => address.office_key,
        "facility_id" => address.facility_id,
        "policy_holder" => {
          "first_name" => "Captain",
          "last_name" => "Jane",
          "date_of_birth" => "01/01/1986",
          "gender" => "female",
          "email" => "test@gmail.com"
        }
      }
    end

    let(:self_insurance_params) do
      {
        "insurance_carrier" => "Aetna",
        "member_id" => "NFC123456",
        "mental_health_phone_number" => "9875551234",
        "primary_policy_holder" => "self"
      }
    end

    it "links the same  responsible party if two dependents use same policy holder details" do
      VCR.use_cassette("amd/update_patient_responsible_coverage_diff_holder_success_new") do
        intake_address
        intake_service = PatientInsuranceIntakeService.new(patient: patient, insurance_params: insurance_params)
        intake_service.save!
        expect(ResponsibleParty.count).to eq(2)
        create(:intake_address, intake_addressable: patient1)
        intake_service = PatientInsuranceIntakeService.new(patient: patient1, insurance_params: insurance_params)
        intake_service.save!
        policy_holder_first_name = insurance_params["policy_holder"]["first_name"]
        responsible_parties = ResponsibleParty.where(first_name: policy_holder_first_name)

        # We expect patient and patient1 to have the same policy_holder (Same responsible party)

        expect(patient.policy_holders.size).to eq(1) # 1 policy_holder
        expect(patient1.policy_holders.size).to eq(1) # 1 policy_holder

        expect(patient.policy_holders.first.id).to eq(patient1.policy_holders.first.id) # Same ID
        expect(patient.policy_holders.first.first_name).to eq(patient1.policy_holders.first.first_name) # Same first name
        expect(patient.policy_holders.first.last_name).to eq(patient1.policy_holders.first.last_name) # Same last name
        expect(patient.policy_holders.first.email).to eq(patient1.policy_holders.first.email) # Same email

        expect(responsible_parties.pluck(:amd_id).uniq.size).to eq(1)
      end
    end
  end
end
