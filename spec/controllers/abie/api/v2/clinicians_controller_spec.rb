require "rails_helper"

RSpec.describe Abie::Api::V2::CliniciansController, type: :request do
  describe " GET clinicians" do
    let!(:postal_code) { create(:postal_code) }

    before do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
    end

    it "returns a 422 unprocessable entity when missing required params" do
      params = { age: 23, type_of_cares: "Adult Therapy", payment_type: "insurance",  utc_offset: "360" }

      token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a 422 unprocessable entity when invalid params are passed" do
      params = {age: 23, distance: 60, type_of_cares: "Adult Therapy", zip_codes: "530001",
                payment_type: "insurance", utc_offset: "360" }

      token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a 200 for valid params" do
      params = { age: 23, type_of_cares: "Adult Therapy", zip_codes: "99950",
                 payment_type: "insurance", utc_offset: "360" }

      token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

      expect(response).to have_http_status(:ok)
    end

    let(:clinician) { create :clinician, license_key: 995456, cbo: 149330}
    let!(:clinician_address) do
      create :clinician_address, :with_clinician_availability, clinician: clinician,
             city: "KASAAN", state: "AK", postal_code: 99950, cbo: 149330,
             latitude: 55.815857, longitude: -132.97985, license_key: clinician.license_key
    end
    let(:type_of_care) do 
      create :type_of_care, clinician: clinician, facility_id: clinician.clinician_addresses.first.facility_id
    end
    let(:postal_code) { create :postal_code }
    let(:insurance) { create :insurance, license_key: clinician.license_key}
    let(:facility_accepted_insurance) do 
      create :facility_accepted_insurance, insurance: insurance, clinician: clinician, 
                                               clinician_address: clinician_address
    end

    it "returns accurate clinician address and clinician data with valid supervised insurances" do
      params = { age: 10, type_of_cares: type_of_care.type_of_care, zip_codes: "99950",
                 payment_type: "self_pay", utc_offset: "420" }

      # Getting the supervised insurances
      insurances = clinician.clinician_addresses.first.insurances.where.not(
        facility_accepted_insurances: { supervisors_name: nil }
      ).pluck(:id, :name).uniq
      keys = %w[id name]
      supervised_insurances = insurances.map { |v| keys.zip v }.map(&:to_h)

      token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)
      response_object = JSON.parse(response.body)

      response_object = response_object["clinicians"][0]

      postal_code = PostalCode.find_by(zip_code:  clinician.clinician_addresses.first.postal_code)
      distance_in_miles =  ClinicianAddress.distance_between_two_points(
        [postal_code&.as_json&.fetch("latitude").to_f,
         postal_code&.as_json&.fetch("longitude").to_f], [clinician.clinician_addresses.first.latitude.to_f,
                                                          clinician.clinician_addresses.first.longitude.to_f]
      )
      response_object["distance_in_miles"] = distance_in_miles

      # Getting clinician_address data
      address_response_object = response_object["addresses"][0]
      # Getting only the clinician data
      response_object.delete("addresses")
      response_object.delete("clinician_availabilities")

      # Mapped clinician type
      expect(response_object["clinician_type"]).to eq(clinician.mapped_clinician_type)

      # Supervised Insurances
      expect(address_response_object["supervised_insurances"]).to eq(supervised_insurances)

      clinician_address = JSON.parse(clinician.clinician_addresses.first.to_json)
      # Removing unused data
      unused_values = %w[distance_in_miles clinician_id created_at updated_at provider_id deleted_at
                         cbo latitude longitude]
      clinician_address = clinician_address.reject! {|key| unused_values.include? key }
      # Checking we get the whole address
      expect(clinician_address.to_a - address_response_object.to_a).to be_empty
    end

    let(:clinician) { create :clinician, license_key: 995456, cbo: 149330}
    let!(:clinician_address) do
      create :clinician_address, :with_clinician_availability, clinician: clinician,
             city: "KASAAN", state: "AK", postal_code: 99950, cbo: 149330,
             latitude: 55.815857, longitude: -132.97985, license_key: clinician.license_key
    end
    let(:type_of_care) do
      create :type_of_care, clinician: clinician, facility_id: clinician.clinician_addresses.first.facility_id
    end
    let(:postal_code) { create :postal_code }

    it "returns accurate clinician address and clinician data without valid supervised insurances" do
      params = { age: 10, type_of_cares: type_of_care.type_of_care, zip_codes: "99950", payment_type: "self_pay",
                 utc_offset: "420" }
      token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)
      response_object = JSON.parse(response.body)

      response_object = response_object["clinicians"][0]

      # Getting clinician_address data
      address_response_object = response_object["addresses"][0]
      # Getting only the clinician data
      response_object.delete("addresses")
      response_object.delete("clinician_availabilities")

      # Mapped clinician type
      expect(response_object["clinician_type"]).to eq(clinician.mapped_clinician_type)

      # Supervised Insurances
      expect(address_response_object["supervised_insurances"]).to be_empty

      clinician_address = JSON.parse(clinician.clinician_addresses.first.to_json)
      # Removing unused data
      unused_values = %w[distance_in_miles clinician_id created_at updated_at provider_id deleted_at
                         cbo latitude longitude]
      clinician_address = clinician_address.reject! {|key| unused_values.include? key }
      # Checking we get the whole address
      expect(clinician_address.to_a - address_response_object.to_a).to be_empty
    end

    context "When insurances are created but not association is created between the insurance and clinician address" do
      let(:clinician) { create :clinician, license_key: 995456, cbo: 149330}
      let!(:clinician_address) do
        create :clinician_address, :with_clinician_availability, clinician: clinician,
               city: "KASAAN", state: "AK", postal_code: 99950, cbo: 149330,
               latitude: 55.815857, longitude: -132.97985, license_key: clinician.license_key
      end
      let(:type_of_care) do
        create :type_of_care, clinician: clinician, facility_id: clinician.clinician_addresses.first.facility_id
      end
      let(:postal_code) { create :postal_code }
      let(:insurance) { create :insurance, license_key: clinician.license_key}
      let(:facility_accepted_insurance) do
        create :facility_accepted_insurance, insurance_id: insurance, clinician_id: clinician,
               clinician_address_id: clinician_address.id + 1
      end
      it "returns an empty supervised_insurances object" do
        params = { age: 10, type_of_cares: type_of_care.type_of_care, zip_codes: "99950", payment_type: "self_pay",
                   utc_offset: "420" }
        token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)
        # Supervised Insurances
        supervised_insurances = JSON.parse(response.body).dig("clinicians", 0, "addresses", 0, "supervised_insurances")

        expect(supervised_insurances).to be_empty
      end
    end
  end

  describe " GET clinician by id" do
    let!(:postal_code) { create(:postal_code) }
    let!(:clinician) { create(:clinician, :with_address) }
    let!(:clinician2) { create(:clinician, :with_address, first_name: 'other', last_name: 'provider') }

    before do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      rsa_public = rsa_private.public_key

      allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
      @token = JWT.encode({
                            app_displayname: 'ABIE',
                            exp: (Time.now+200).strftime('%s').to_i
                          }, rsa_private, 'RS256')
    end

    it "returns a 422 status if jwt is not passed" do
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", params: {}, token: nil)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a 200, when optional param app_name is not passed" do
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", token: @token)

      expect(response).to have_http_status(:ok)
    end

    it "returns a 200, when optional param app_name is passed" do
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", params: { app_name: 'abie' }, token: @token)

      expect(response).to have_http_status(:ok)
    end

    it "returns status not found, when an invalid clinician is passed as param" do
      clinician = rand(100)
      token_encoded_get("/abie/api/v2/clinician/#{clinician}", params: { app_name: 'abie' }, token: @token)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 200, when we request other_providers" do
      params = {other_providers: true}
      token_encoded_get("/abie/api/v2/clinician/#{clinician2.id}", params: params, token: @token)

      expect(response).to have_http_status(:ok)
    end
  end
end