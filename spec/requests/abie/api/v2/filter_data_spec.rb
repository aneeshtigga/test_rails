require "rails_helper"

RSpec.describe "Filter Data", type: :request do
  describe "GET /abie/api/v2/filter_data" do
    before do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
      
      GenderIdentity.delete_all
      create(:gender_identity, :male)
      create(:gender_identity, :female)
      create(:gender_identity, :neither)
    end

    describe "Location Data" do
      it "returns location filter data" do
        postal_code = create(:postal_code)
        address = create(:clinician_address, clinician: create(:clinician), postal_code: postal_code.zip_code)
        care = create(:type_of_care, clinician_id: address.clinician_id, facility_id: address.facility_id)

        params = { zip_code: postal_code.zip_code, type_of_care: care.type_of_care }
        token_encoded_get("/abie/api/v2/filter_data", params: params, token: @token)

        location_info = {
          "address_line1" => address.address_line1,
          "address_line2" => address.address_line2,
          "city" => address.city,
          "facility_id" => address.facility_id,
          "facility_name" => address.facility_name,
          "distance_in_miles" => 2754.51
        }

        expect(json_response["locations"].first).to include(location_info)
        expect(json_response["special_cases"]).to eq([])
        expect(json_response["expertises"]).to eq([])
      end

      describe "Expertise Data" do
        it "returns active clinician expertises" do
          clinician = create(:clinician)
          inactive_clinician = create(:clinician, :inactive)

          expertise = create(:expertise, name: "active expertise")
          inactive_expertise = create(:expertise, name: "not active expertise", active: false)

          clinician.expertises << expertise
          inactive_clinician.expertises << inactive_expertise

          params = {}

          token_encoded_get("/abie/api/v2/filter_data", params: params, token: @token)
          expertises_data = [expertise.as_json]

          expect(json_response["expertises"]).to eq(expertises_data)
        end
      end

      describe "Concerns Data" do
        it "returns active clinician concerns" do
          active_clinician = create(:clinician)
          inactive_clinician = create(:clinician, :inactive)

          active_concern = create(:concern, name: "active concern")
          inactive_concern = create(:concern, name: "not active concern", active: false)

          active_clinician.concerns << active_concern
          inactive_clinician.concerns << inactive_concern

          params = { patient_type: "child" }

          token_encoded_get("/abie/api/v2/filter_data", params: params, token: @token)
          concerns_data = [active_concern.as_json]

          expect(json_response["concerns"]).to eq(concerns_data)
        end
      end

      describe "gender_identity" do 
        it "returns gender_identity" do 
          token_encoded_get("/abie/api/v2/filter_data", params: {}, token: @token)

          gi_data = %w[Male Female Rock].as_json

          expect(json_response["gender_identity"]).to eq(gi_data)
        end
      end

      describe "Marketing Referrals Data" do
        it "returns the possible marketing referrals" do
          # These would be created/edited by active admin
          marketing_referral = create(:marketing_referral, display_marketing_referral: "Second", order: 2)
          marketing_referral2 = create(:marketing_referral, display_marketing_referral: "First", order: 1)
          marketing_referral3 = create(:marketing_referral, active: false)

          token_encoded_get("/abie/api/v2/filter_data", token: @token)

          # We expect to get only the active marketing referrals
          expect(json_response["marketing_referrals"].size).to eq(2)
          
          # We expect the first marketing referral to be ordered by the order column
          expect(json_response["marketing_referrals"][0]["display_marketing_referral"]).to eq("First")
        end
      end

      describe "Searching nearby zipcode" do
        let!(:nearby_zip_codes) { { '60_mile': %w[44141 44142] } }
        let!(:postal_code) { create(:postal_code, zip_code: "44122", zip_codes_by_radius: nearby_zip_codes) }
        let!(:nearby_zip_code) { "44141" }
        let!(:nearby_address) do
          create(:clinician_address, clinician: create(:clinician), postal_code: nearby_zip_code)
        end
        let!(:care) do
          create(:type_of_care, clinician_id: nearby_address.clinician_id, facility_id: nearby_address.facility_id)
        end

        let!(:nearby_location_info) do
          {
            "address_line1" => nearby_address.address_line1,
            "address_line2" => nearby_address.address_line2,
            "city" => nearby_address.city,
            "facility_id" => nearby_address.facility_id,
            "facility_name" => nearby_address.facility_name
          }
        end

        let!(:current_zip_code) { "44122" }
        let(:current_address) do
          create(:clinician_address, address_line1: "test address", clinician: create(:clinician),
                                     postal_code: current_zip_code)
        end

        let(:current_location_info) do
          {
            "address_line1" => current_address.address_line1,
            "address_line2" => current_address.address_line2,
            "city" => current_address.city,
            "facility_id" => current_address.facility_id,
            "facility_name" => current_address.facility_name
          }
        end

        it "searches nearby zip codes for location data" do
          params = { zip_code: postal_code.zip_code, type_of_care: care.type_of_care }
          token_encoded_get("/abie/api/v2/filter_data", params: params, token: @token)

          expect(json_response["locations"].first).to include(nearby_location_info)
          expect(json_response["special_cases"]).to eq([])
          expect(json_response["expertises"]).to eq([])
        end

        it "returns location data of current and nearby zipcode" do
          current_address
          params = { zip_code: postal_code.zip_code, type_of_care: care.type_of_care }
          token_encoded_get("/abie/api/v2/filter_data", params: params, token: @token)

          expect(json_response["locations"].first).to include(nearby_location_info)
        end
      end
    end
  end
end
