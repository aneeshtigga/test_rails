require "rails_helper"

describe AmdAccountLookupService, type: :class do
  let(:params) do
    {
      first_name: "ADDISON",
      last_name: "ANDRIEU",
      date_of_birth: "01/23/1980",
      email: "ANDRIEU.ADDISON@EXAMPLE.COM",
      gender: "female"
    }
  end

  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:account_holder) { create(:account_holder, params) }
  let!(:clinician) { create(:clinician, provider_id: 123) }
  let!(:clinician_address) { create(:clinician_address, clinician: clinician, postal_code: "74073", provider_id: clinician.provider_id, office_key: 995456) }
  let(:account_lookup) { AmdAccountLookupService.new(params, clinician_address.office_key) }

  before do
    authenticate_amd_api
  end

  describe "#existing_accounts" do
    context "responsible party exists" do
      it "returns all patients account is responsible for" do
        VCR.use_cassette('lookup_existing_responsible_parties_success') do
          expect(account_lookup.existing_accounts[:responsible_party_patients].first).to include(
            id: "family5982454",
            first_name: "ADDISON",
            last_name: "ANDRIEU",
            responsible_party: true
          )
        end
      end
    end

    context "responsible party does not exist" do
      let(:params) do
        {
          first_name: "ADDISON",
          last_name: "ANDRIE",
          date_of_birth: "01/23/1980"
        }
      end

      it "returns an empty array" do
        VCR.use_cassette('amd/lookup_existing_responsible_parties_no_records_success') do
          expect(account_lookup.existing_accounts).to eq(responsible_party_patients: [])
        end
      end
    end
  end
end
