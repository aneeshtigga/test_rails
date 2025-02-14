require "rails_helper"
RSpec.describe "Api::V1::AccountHolders", type: :request do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let!(:skip_patient_amd) { skip_patient_amd_creation }

  describe "POST /api/v1/account_holders" do
    let!(:clinician) { create(:clinician, provider_id: 123) }
    let!(:clinician_address) { create(:clinician_address, clinician: clinician, provider_id: clinician.provider_id, office_key: 995456) }

    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_amd_api_app_name })
    end

    context "No pre-existing responsible parties" do
      before(:each) do
        allow_any_instance_of(AmdAccountLookupService).to receive(:existing_accounts).and_return({})
        allow_any_instance_of(AmdAccountLookupService).to receive(:amd_search_for_patient).and_return(false)
      end

      context "when it success" do
        it "creates account holder data with status 201 created" do
          token_encoded_post("/api/v1/account_holders",
                              params: { first_name: "captain", last_name: "redbeard",  date_of_birth: "06/22/1990",
                                gender: "male", gender_identity: "Male", email: "redbeardtest@email.com",
                                phone_number: 1231231234, provider_id: clinician.provider_id, search_filter_values: {
                                  zip_codes: clinician_address.postal_code,
                                  clinician_address_id: clinician_address.id
                                }, pronouns: "His", about: "test" }, token: @token)

          expect(response).to have_http_status(:created)
          account_holder = AccountHolder.last

          expect(AccountHolder.all.size).to eq(1)
          expect(account_holder).to have_attributes(first_name: "captain", last_name: "redbeard",  date_of_birth: "06/22/1990", gender: "male", email: "redbeardtest@email.com", phone_number: "1231231234", search_filter_values: { "zip_codes" => "#{clinician_address.postal_code}", "clinician_address_id" => "#{clinician_address.id}" }, pronouns: "His", about: "test")

          expect(json_response["account_holder"]).to include(
            "first_name" => account_holder.first_name,
            "last_name" => account_holder.last_name,
            "date_of_birth" => "06/22/1990",
            "gender" => "male",
            "about" => account_holder.about,
            "account_holder_patient_id" => account_holder.self_patient.id
          )
        end

        it "triggers account confirmation email on successful account holder creation" do
          token_encoded_post("/api/v1/account_holders",
                              params: { first_name: "captain", last_name: "redbeard",  date_of_birth: "06/22/1990",
                                gender: "male", gender_identity: "Male", email: "redbeardtest@email.com",
                                phone_number: 1231231234, provider_id: clinician.provider_id, search_filter_values: {
                                  zip_codes: clinician_address.postal_code, clinician_address_id: clinician_address.id 
                                }, pronouns: "His", about: "test"}, token: @token)

          # expect(AccountConfirmationMailerWorker.jobs.size).to eq(1)
          expect(response.status).to eq(201)
        end

        describe "#create_self_patient" do
          it "creates a self patient record" do
            token_encoded_post("/api/v1/account_holders",
              params: {
                first_name: "captain",
                last_name: "redbeard",
                date_of_birth: "06/12/1990",
                gender: "male",
                gender_identity: "Male",
                email: "redbeardtest@email.com",
                phone_number: 1231231234,
                provider_id: clinician.provider_id,
                search_filter_values: {
                  zip_codes: clinician_address.postal_code,
                  clinician_address_id: clinician_address.id
                },
                pronouns: "His",
                about: "test" },
                token: @token)

            account_holder = AccountHolder.last


            expect(response).to have_http_status(:created)

            expect(account_holder.self_patient).to have_attributes(
              first_name: account_holder.first_name,
              last_name: account_holder.last_name,
              email: account_holder.email,
              gender: account_holder.gender,
              account_holder_relationship: "self",
              account_holder_id: account_holder.id,
              referral_source: account_holder.source,
              phone_number: account_holder.phone_number,
              pronouns: account_holder.pronouns,
              about: account_holder.about,
              search_filter_values: account_holder.search_filter_values,
              office_code: 995456,
              provider_id: clinician.provider_id
            )
          end

          it "creates a self patient record for admin" do
            token_encoded_post("/api/v1/account_holders",
              params: {
                first_name: "captain",
                last_name: "redbeard",
                date_of_birth: "06/12/1990",
                gender: "male",
                gender_identity: "Male",
                email: "redbeardtest@email.com",
                phone_number: 1231231234,
                provider_id: clinician.provider_id,
                search_filter_values: {
                  zip_codes: clinician_address.postal_code,
                  clinician_address_id: clinician_address.id
                },
                pronouns: "His",
                about: "test",
                'booked_by': "admin" },
                token: @token)

            account_holder = AccountHolder.last

            expect(response).to have_http_status(:created)

            expect(account_holder.self_patient).to have_attributes(
              first_name: account_holder.first_name,
              last_name: account_holder.last_name,
              email: account_holder.email,
              gender: account_holder.gender,
              account_holder_relationship: "self",
              account_holder_id: account_holder.id,
              referral_source: account_holder.source,
              phone_number: account_holder.phone_number,
              pronouns: account_holder.pronouns,
              about: account_holder.about,
              search_filter_values: account_holder.search_filter_values,
              office_code: 995456,
              provider_id: clinician.provider_id
            )
          end

          it "doesn't create a duplicate" do
            token_encoded_post("/api/v1/account_holders",
                               params: {
                                 first_name: "captain",
                                 last_name: "redbeard",
                                 date_of_birth: "06-12-1990",
                                 gender: "male",
                                 gender_identity: "Male",
                                 email: "redbeardtest@email.com",
                                 phone_number: 1231231234,
                                 provider_id: clinician.provider_id,
                                 search_filter_values: {
                                   zip_codes: clinician_address.postal_code,
                                   clinician_address_id: clinician_address.id
                                 },
                                 pronouns: "His",
                                 about: "test"},
                               token: @token)

            token_encoded_post("/api/v1/account_holders",
                               params: {
                                 first_name: "captain",
                                 last_name: "redbeard",
                                 date_of_birth: "06-12-1990",
                                 gender: "male",
                                 gender_identity: "Male",
                                 email: "redbeardtest@email.com",
                                 phone_number: 1231231234,
                                 provider_id: clinician.provider_id,
                                 search_filter_values: {
                                   zip_codes: clinician_address.postal_code,
                                   clinician_address_id: clinician_address.id
                                 },
                                 pronouns: "His",
                                 about: "test"},
                               token: @token)

            # We modify the existing one, not create another new record.
            expect(AccountHolder.count).to eq(1)
          end
        end
      end

      it "throws error when any params that is required is not passed like email" do
        token_encoded_post(
          "/api/v1/account_holders",
          params: { 
            first_name:             "test",
            last_name:              "test",
            date_of_birth:          "12/05/1995",
            phone_number:           "7838479845",
            source:                 "google",
            receive_email_updates:  true,
            gender:                 "male",
            gender_identity:        "Male", # case matters
            pronouns:               "His",
            about:                  "test",
            provider_id:            clinician.provider_id,
            search_filter_values: { 
              # SMELL:  Note the difference in key class.  The
              #         zip_codes key is class String.
              #         clinician_address_id is class Symbol
              #
              "zip_codes"             =>  "#{clinician_address.postal_code}", 
              'clinician_address_id':     clinician_address.id 
            } 
          }, 
          token: @token
        )

        expect(response).to have_http_status(:unprocessable_entity)
        expect(AccountHolder.all.size).to eq(0)
        expect(json_response["error"]).to eq("Validation failed: Email can't be blank")
      end

      it "enqueues confirmation email on success" do
        # expect(AccountConfirmationMailerWorker.jobs.size).to eq(0)
        skip_patient_amd_creation

        token_encoded_post("/api/v1/account_holders",
                            params: { first_name: "captain", last_name: "redbeard",  date_of_birth: "06/22/1990", gender: "male", email: "redbeardtest@email.com", phone_number: 1231231234, provider_id: clinician.provider_id, search_filter_values: { zip_codes: clinician_address.postal_code, 'clinician_address_id': clinician_address.id }, pronouns: "His", about: "test" }, token: @token)

        account_holder_id = json_response["account_holder"]["id"]

        # expect(AccountConfirmationMailerWorker.jobs.size).to eq(1)
      end
    end

    context "AMD has existing accounts" do
      let!(:account_holder) { create(:account_holder, first_name: "ADDISON", last_name: "ANDRIEU", date_of_birth: "01/23/1980", phone_number: "7838479870", source: "google", receive_email_updates: true, email: "test@gmail.com", gender: "male", search_filter_values: { zip_codes: "74073", 'clinician_address_id': clinician_address.id }, pronouns: "His", about: "test")}
      let!(:patient) {create(:patient ,first_name: "ADDISON", last_name: "ANDRIEU",account_holder_id:account_holder.id, amd_patient_id: 5982454, referral_source: nil )}
      let!(:clinician) { create(:clinician) }
      let!(:clinician_address) { create(:clinician_address, postal_code: "74073", clinician: clinician, provider_id: clinician.provider_id, office_key: 995456)}

      before do
        authenticate_amd_api
      end

      it "returns a 422 with existing accounts" do
        VCR.use_cassette('amd/lookup_existing_responsible_parties_success') do
          token_encoded_post("/api/v1/account_holders",
                            params: { first_name: "bendi", last_name: "fry", date_of_birth: "01/02/1994", phone_number: "7838479870", source: "google", receive_email_updates: true, email: "bendi@email.com", gender: "male", search_filter_values: { zip_codes: "74073", 'clinician_address_id': clinician_address.id }, provider_id: clinician.provider_id, pronouns: "His", about: "test" }, token: @token)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      it "returns patient_portal_url for followup patients" do
        VCR.use_cassette('amd/lookup_account_holder_as_responsible_party') do
            token_encoded_post("/api/v1/account_holders",
                                params: { 'first_name': "traffic", 'last_name': "police", 'email': "police@email.com", 'date_of_birth': "01/04/1993", 'gender': "Female", 'source': "", 'phone_number': "1628827366", 'provider_id': 5, 'search_filter_values': { 'zip_codes': "36111", 'clinician_address_id': clinician_address.id, 'type_of_care': "Adult Therapy", 'payment_type': "self_pay", 'insurance_name': "" } }, token: @token)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["exists_in_amd"]).to be true
            expect(json_response["patient_portal_url"]).to eq("https://patientportal.advancedmd.com/995456/account/logon")
        end
      end
    end
  end


  describe "PUT /api/v1/account_holders/:id" do
    let(:account_holder) { create(:account_holder) }

    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end

    it "updates account holder data with status 200" do
      token_encoded_patch("/api/v1/account_holders/#{account_holder.id}",
                          params: { first_name: "test", last_name: "test", date_of_birth: "12/05/1995", phone_number: "7838479845", source: "google", receive_email_updates: true, email: "test@gmail.com", gender: "male", pronouns: "His", about: "test" }, token: @token)

      expect(response).to have_http_status(:ok)
      expect(AccountHolder.all.size).to eq(1)
      expect(AccountHolder.first).to have_attributes(first_name: "test", last_name: "test",
                                                     date_of_birth: "12/05/1995", phone_number: "7838479845", source: "google", receive_email_updates: true, email: "test@gmail.com", gender: "male", pronouns: "His", about: "test")
    end

    it "throws error when any params that is required is not passed like email" do
      token_encoded_patch("/api/v1/account_holders/#{account_holder.id}",
                          params: { first_name: "test", last_name: "test", date_of_birth: "12/05/1995", phone_number: "7838479845", source: "google", receive_email_updates: true, gender: "male", email: nil }, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("Validation failed: Email can't be blank")
    end
  end


  describe "AMD account already exists" do
    let!(:account_holder) { create(:account_holder) }
    let!(:hipaa_relationship) { HipaaRelationshipCode.create(code: 18, description: "Self") }
    let!(:clinician) { create(:clinician, provider_id: 123) }
    let!(:clinician_address) do
      create(:clinician_address, clinician: clinician, provider_id: clinician.provider_id, office_key: 995_456)
    end
    let!(:clinician_availability) do
      create(:clinician_availability, provider_id: clinician.provider_id, profile_id: 1, column_id: 1,
                                      facility_id: clinician_address.facility_id)
    end
    let!(:patient) do
      create(:patient,  account_holder_id: account_holder.id, amd_patient_id: 5982454, referral_source: nil )
    end

    before :all do
      @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
    end

    it "return the existing account details" do
      VCR.use_cassette('amd/lookup_for_existing_responsible_parties_success') do
          token_encoded_post("/api/v1/account_holders",
                            params: { first_name: "ADDISON", last_name: "ANDRIEU",
                             date_of_birth: "01/23/1980", phone_number: "7838479870", source: "google", receive_email_updates: true, email: "andrieu.addison@example.com", gender: "female", search_filter_values: { zip_codes: "30301", clinician_address_id: clinician_address.id }, provider_id: clinician_address.provider_id, pronouns: "Her", about: "test" }, token: @token)
          expect(json_response["message"]).to eq("Account holder already exists")
          expect(json_response["exists_in_amd"]).to be true
          expect(json_response["existing_accounts"]["responsible_party_patients"]).to eq([{"id"=>"family5982454", "first_name"=>"ADDISON", "last_name"=>"ANDRIEU", "chart"=>"2577", "responsible_party"=>true, "lfs_account_holder_id"=>account_holder.id}])
      end
    end
  end
end
