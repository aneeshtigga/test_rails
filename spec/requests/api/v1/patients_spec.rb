require "rails_helper"

RSpec.describe "Api::V1::Patients", type: :request do
  before :all do
    @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
  end

  before do
    allow_any_instance_of(Patient).to receive(:amd_patient).and_return(nil)
  end

  describe "POST /api/v1/patients " do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let(:account_holder) { create(:account_holder) }
    let(:special_case) { create(:special_case) }
    let(:clinician) { create(:clinician) }
    let(:clinician_address) { create(:clinician_address, clinician: clinician) }
    it "creates patient as child with all required params and return 200 response" do
      VCR.use_cassette("amd/push_referral") do
        token_encoded_post("/api/v1/patients",
                           params: { first_name: "test",
                                     last_name: "test",
                                     preferred_name: "test",
                                     date_of_birth: "12/05/1995",
                                     phone_number: "7838479870",
                                     referral_source: "Search engine (Google, Bing, etc.)",
                                     pronouns: "His",
                                     about: "test",
                                     account_holder_relationship: "child",
                                     account_holder_id: account_holder.id,
                                     credit_card_on_file_collected: false,
                                     intake_status: "patient_profile_info",
                                     special_case_id: special_case.id,
                                     provider_id: clinician.provider_id,
                                     referring_provider_name: "Search engine",
                                     referring_provider_phone_number: "+917838479870",
                                     search_filter_values: { zip_codes: clinician_address.postal_code },
                                     gender: "male" }, token: @token)
      end

      expect(response).to have_http_status(:ok)
      expect(Patient.all.size).to eq(1)
    end

    it "throws error when any params that is required is not passed like account_holder_id" do
      token_encoded_post("/api/v1/patients",
                         params: { first_name: "test",
                                   last_name: "test",
                                   preferred_name: "test",
                                   date_of_birth: "12/05/1995",
                                   phone_number: "7838479870",
                                   referral_source: "google",
                                   pronouns: "His",
                                   about: "test",
                                   account_holder_relationship: "child",
                                   credit_card_on_file_collected: false,
                                   intake_status: "patient_profile_info",
                                   special_case_id: special_case.id,
                                   provider_id: clinician.provider_id,
                                   referring_provider_name: "Search engine",
                                   referring_provider_phone_number: "+917838479870",
                                   gender: "male" }, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Patient.all.size).to eq(0)
    end
  end

  describe "PATCH /api/v1/patients/:id" do
    let!(:skip_patient_amd) { skip_patient_amd_creation }
    let!(:clinician_address) { create(:clinician_address) }
    context "when request is valid" do
      let(:patient) { create(:patient, marketing_referral_id: "123", special_case_id: nil) }
      # In order to modify a patient, the patient should not exist on AMD, so it should not have an amd_patient_id
      let(:params) do
        { 
          first_name: patient.first_name, 
          last_name: patient.last_name, 
          date_of_birth: patient.date_of_birth, 
          email: patient.email,
          preferred_name: "Captain Blackbeard", 
          pronouns: "Other", 
          about: "Test information" 
        }
      end

      it "updates the record" do
        VCR.use_cassette("amd/post_patient_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)
        end
        patient.reload

        expect(response).to have_http_status(200)
        expect(patient.preferred_name).to eq("Captain Blackbeard")
        expect(patient.pronouns).to eq("Other")
        expect(patient.about).to eq("Test information")
      end

      it "returns status code 200" do
        VCR.use_cassette("amd/post_patient_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)
        end

        expect(response).to have_http_status(200)
      end
    end

    context "update data of patient" do
      let(:patient) { create(:patient, marketing_referral_id: "123") }

      it "update special case data of patient" do
        clinician = create(:clinician)
        special_case = create(:special_case)
        create(:clinician_special_case, special_case: special_case, clinician: clinician)
        params = { special_case_id: special_case.id, clinician_id: clinician.id, intake_status: "confirmation_screen" }

        VCR.use_cassette("amd/post_custom_patients_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)

          patient.reload
          expect(response.body).to_not be_empty
          expect(patient.special_case).to eq(special_case)
          expect(json_response["clinician_match_flag"]).to eq(true)
        end
      end

      it "update disorders data of patient" do
        concern = create(:concern)
        population = create(:population)
        population2 = create(:population)
        intervention = create(:intervention)
        special_case = create(:special_case)
        patient_disorder = create(:patient_disorder, concern: concern, patient_id: patient.id)

        params = { special_case_id: special_case.id,
                   patient_concerns: [{ concern_id: concern.id }],
                   patient_populations: [{ "population_id" => population.id },
                                         { "population_id" => population2.id }],
                   patient_interventions: [{ "intervention_id" => intervention.id }],
                   intake_status: "prepare_for_visit" }


        VCR.use_cassette("amd/post_custom_patients_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)
          patient.reload
        end

        expect(response.body).to_not be_empty
        expect(patient.concerns).to match_array([concern])
        expect(patient.populations.count).to be(2)
        expect(patient.interventions.count).to be(1)

      end

      it "update disorders data of patient" do
        concern1 = create(:concern)
        concern2 = create(:concern)
        special_case = create(:special_case)
        params = { special_case_id: special_case.id, patient_concerns:
          [{ concern_id: concern1.id },
           { concern_id: concern2.id }], intake_status: "prepare_for_visit" }

        VCR.use_cassette("amd/post_custom_patients_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)
        end

        patient.reload

        expect(response.body).to_not be_empty
        expect(patient.concerns).to match_array([concern1, concern2])
      end
    end

    context "when request is invalid" do
      let(:patient) { create(:patient, marketing_referral_id: "123") }

      params = { preferred_name: "T3$t!nG", pronouns: "Other", about: "Test information" }

      it "returns status code 422" do
        VCR.use_cassette("amd/post_custom_patients_updates_fail") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)
        end

        expect(response).to have_http_status(422)
      end

      it "contains an error message" do
        VCR.use_cassette("amd/post_custom_patients_updates_fail") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)
        end

        expect(json_response["message"]).to include("Error occured in saving patient information")
        expect(json_response["error"]).to include("Preferred name only allows letters")
      end
    end

    context "when patient is not found" do
      params = { preferred_name: "Captain Blackbeard", pronouns: "Other", about: "Test information" }

      before { token_encoded_patch("/api/v1/patients/0", params: params, token: @token) }

      it "returns status code 404" do
        expect(response).to have_http_status(404)
      end

      it "contains an error message" do
        expect(json_response["message"]).to include("Patient not found")
      end
    end

    context "update special case of patient and pass clinician match flag or not" do
      let(:patient) { create(:patient, marketing_referral_id: "123") }

      it "clinician match case" do
        clinician = create(:clinician)
        special_case = create(:special_case)
        create(:clinician_special_case, special_case: special_case, clinician: clinician)
        params = { special_case_id: special_case.id, clinician_id: clinician.id }
        VCR.use_cassette("amd/post_custom_patients_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)

          patient.reload
          expect(response.body).to_not be_empty
          expect(patient.special_case).to eq(special_case)
          expect(json_response["clinician_match_flag"]).to eq(true)
        end
      end

      it "clinician doesn't not match case" do
        clinician = create(:clinician)
        special_case = create(:special_case)
        params = { special_case_id: special_case.id, clinician_id: clinician.id, intake_status: "prepare_for_visit"}
        VCR.use_cassette("amd/post_custom_patients_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)

          patient.reload
          expect(response.body).to_not be_empty
          expect(patient.special_case).to eq(special_case)
          expect(json_response["clinician_match_flag"]).to eq(false)
        end
      end

      it "special_case with name 'None of the Above'" do
        clinician = create(:clinician)
        special_case = create(:special_case, name: "None of the above")
        params = { special_case_id: special_case.id, clinician_id: clinician.id }
        VCR.use_cassette("amd/post_none_special_case_updates") do
          token_encoded_patch("/api/v1/patients/#{patient.id}", params: params, token: @token)

          patient.reload
          expect(response.body).to_not be_empty
          expect(patient.special_case).to eq(special_case)
          expect(json_response["clinician_match_flag"]).to eq(true)
        end
      end
    end
  end
end
