require "rails_helper"

RSpec.describe "Api::V1::Zipcodes", type: :request do
  describe " GET /api/v1/validate_zip " do
    let(:postal_code) { create(:postal_code) }

    before do
      @token = JsonWebToken.encode({
                                     application_name: Rails.application.credentials.ols_api_app_name
                                   })

      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token2 = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
    end

    it "returns a 404 for invalid zip code" do
      token_encoded_get("/api/v1/validate_zip", params: { address_info: { zip_code: "530001" } }, token: @token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns a 200 for valid zip code" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(response).to have_http_status(:ok)
    end

    it "returns a 401 status if jwt token not passed" do
      token_encoded_get("/api/v1/validate_zip", params: {})

      expect(response).to have_http_status(:unauthorized)
      expect(json_response["message"]).to eq("Jwt token expired or invalid")
    end

    it "returns with city name for valid zipcode" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("city")
      expect(json_response["city"]).to eq(postal_code.city)
    end

    it "returns with state name for valid zip code" do
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("state")
      expect(json_response["state"]).to eq(postal_code.state)
    end

    it "returns accepted insurances by state of the valid zip code" do
      clinician = create(:clinician)
      address = create(:clinician_address, clinician: clinician, state: postal_code.state)
      insurance = create(:insurance)
      create(:facility_accepted_insurance, insurance: insurance, clinician_address: address)
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("state")
      expect(json_response["insurances"]).to include(insurance.name)
    end

    it "returns list of type of cares offered for the state of the ZIP code" do
      address = create(:clinician_address, clinician: create(:clinician), state: postal_code.state)
      care = create(:type_of_care, clinician_id: address.clinician_id, facility_id: address.facility_id)
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("type_of_cares")
      expect(json_response["type_of_cares"]).to match_array([care.type_of_care])
    end

    describe "No data is returned for zipcode" do
      let(:nearby_zip_codes) { { '60_mile': %w[44141 44142] } }
      let(:postal_code) { create(:postal_code, zip_code: "44122", zip_codes_by_radius: nearby_zip_codes) }

      it "searches nearby zip codes" do
        params = { address_info: { zip_code: postal_code.zip_code } }

        nearby_zip_code = "44141"
        clinician = create(:clinician)
        address = create(:clinician_address, clinician: clinician, state: postal_code.state)

        insurance = create(:insurance)
        create(:facility_accepted_insurance, insurance: insurance, clinician_address: address)
        care = create(:type_of_care, clinician_id: address.clinician_id, facility_id: address.facility_id)

        token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

        expect(json_response["insurances"]).to include(insurance.name)
        expect(json_response["type_of_cares"]).to match_array([care.type_of_care])

        expect(json_response["nearby_search"]).to eq(true)
      end
    end

    it "returns list of type of cares offered in sorted order" do
      address = create(:clinician_address, clinician: create(:clinician), state: postal_code.state)
      care1 = create(:type_of_care, type_of_care: "Adult Psychiatry", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)
      care2 = create(:type_of_care, type_of_care: "Child Therapy", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("type_of_cares")
      expect(json_response["type_of_cares"]).to match_array([care1.type_of_care, care2.type_of_care])
    end

    it "returns list of insurances offered in sorted order" do
      address = create(:clinician_address, clinician: create(:clinician), state: postal_code.state)
      insurance1 = create(:insurance, name: "Adventist")
      create(:facility_accepted_insurance, insurance: insurance1, clinician_address: address)
      insurance2 = create(:insurance, name: "Humana")
      create(:facility_accepted_insurance, insurance: insurance2, clinician_address: address)

      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("insurances")
      expect(json_response["insurances"]).to match_array([insurance1.name, insurance2.name,
                                                          "I don’t see my insurance"])
    end

    it "returns nearby_search true even for exact zip_code search" do
      clinician = create(:clinician)
      address = create(:clinician_address, clinician: clinician, postal_code: postal_code.zip_code)
      insurance = create(:insurance)
      create(:facility_accepted_insurance, insurance: insurance, clinician_address: address)
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response["nearby_search"]).to eq(true)
    end

    describe "60miles geosearch for exact match" do
      let!(:nearby_zipcode) { "44141" }
      let!(:nearby_postal_data) { create(:postal_code, zip_code: nearby_zipcode) }

      let!(:current_zipcode) { "44140" }
      let!(:current_postal_data) do
        create(:postal_code, zip_code: current_zipcode, zip_codes_by_radius: { '60_mile': [nearby_zipcode, "44142"] })
      end

      let!(:clinician) { create(:clinician) }
      let!(:clinician_address) { create(:clinician_address, postal_code: nearby_zipcode) }
      let(:type_of_care) do
        create(:type_of_care, facility_id: clinician_address.facility_id, amd_license_key: clinician_address.office_key)
      end

      let(:clinician_address2) { create(:clinician_address, postal_code: current_zipcode) }

      let!(:insurance) { create(:insurance) }
      let!(:facility_accepted_insurance) do
        create(:facility_accepted_insurance, insurance_id: insurance.id, clinician_address_id: clinician_address.id)
      end

      before do
        rsa_private = OpenSSL::PKey::RSA.generate 2048
        rsa_public = rsa_private.public_key

        allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
        @token2 = JWT.encode({
                              app_displayname: 'ABIE',
                              exp: (Time.now+200).strftime('%s').to_i
                            }, rsa_private, 'RS256')
      end

      it "returns nearby_search insurances if no insurances available for current zipcode" do
        params = { address_info: { zip_code: current_zipcode } }
        token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

        expect(Insurance.accepted_insurances_by_state(postal_code.state, "obie")).to be_empty
        expect(json_response["insurances"]).to include(*Insurance.accepted_insurances_by_state(postal_code.state, "obie"))
      end

      it "returns nearby_search insurances and insurances available for current zipcode" do
        params = { address_info: { zip_code: current_zipcode } }
        insurance = create(:insurance, name: "Anthem")
        create(:facility_accepted_insurance, insurance_id: insurance.id, clinician_address_id: clinician_address2.id)
        token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

        expect(json_response["insurances"]).to include(*Insurance.accepted_insurances_by_state(postal_code.state, "obie"))
      end

      it "returns nearby_search type_of_cares if no type_of_cares available for current zipcode" do
        params = { address_info: { zip_code: current_zipcode } }
        token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

        expect(TypeOfCare.get_cares_by_state(postal_code.state)).to be_empty
        expect(json_response["type_of_cares"]).to eq(TypeOfCare.get_cares_by_state(postal_code.state))
      end

      it "returns nearby_search type_of_cares and type_of_cares available for current zipcode" do
        params = { address_info: { zip_code: current_zipcode } }
        create(:type_of_care, facility_id: clinician_address2.facility_id,
                              amd_license_key: clinician_address2.office_key)

        token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

        expect(json_response["type_of_cares"]).to eq(TypeOfCare.get_cares_by_state(postal_code.state))
      end
    end

    it "returns list of non testing type of cares for OBIE" do
      address = create(:clinician_address, clinician: create(:clinician), state: postal_code.state)
      care1 = create(:type_of_care, type_of_care: "Adult Psychiatry", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)
      care2 = create(:type_of_care, type_of_care: "Child Therapy", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)
      care3 = create(:type_of_care, type_of_care: "Psych Testing", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("type_of_cares")
      expect(json_response["type_of_cares"]).to_not include(care3.type_of_care)
      expect(json_response["type_of_cares"]).to match_array([care1.type_of_care, care2.type_of_care])
    end

    it "returns list of type of cares including testing for ABIE" do
      address = create(:clinician_address, clinician: create(:clinician), state: postal_code.state)
      care1 = create(:type_of_care, type_of_care: "Adult Psychiatry", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)
      care2 = create(:type_of_care, type_of_care: "Child Therapy", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)
      care3 = create(:type_of_care, type_of_care: "Psych Testing", clinician_id: address.clinician_id,
                                    facility_id: address.facility_id)

      params = { address_info: { zip_code: postal_code.zip_code }, app_name: "abie" }

      token_encoded_get("/api/v1/validate_zip", params: params, token: @token2)

      expect(json_response["type_of_cares"]).to match_array([care1.type_of_care, care2.type_of_care, care3.type_of_care])
    end

    it "returns list of insurances for valid zipcodes" do
      address = create(:clinician_address, state: postal_code.state)
      insurance1 = create(:insurance, name: "Adventist")
      create(:facility_accepted_insurance, insurance: insurance1, clinician_address: address)
      insurance2 = create(:insurance, name: "Humana")
      create(:facility_accepted_insurance, insurance: insurance2, clinician_address: address)
      params = { address_info: { zip_code: postal_code.zip_code } }
      token_encoded_get("/api/v1/validate_zip", params: params, token: @token)

      expect(json_response).to include("insurances")
      expect(json_response["insurances"]).to include("I don’t see my insurance")
      expect(json_response["insurances"].last).to eq("I don’t see my insurance")
    end
  end
end
