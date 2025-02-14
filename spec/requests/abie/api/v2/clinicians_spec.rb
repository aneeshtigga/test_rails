require "rails_helper"

RSpec.describe "Clinicians", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday
  let!(:postal_code) { create(:postal_code, zip_code: "30301") }

  before do
    Clinician.destroy_all
    create(:postal_code, zip_code: "12345", city: "Fake City", state: "DC")
    create(:postal_code, zip_code: "44122", city: "Beachwood", state: "OH")

    travel_to stub_time
  end

  after do
    travel_back
  end

  describe "GET /abie/api/v2/clinicians" do
    context "when there is a clinician with availability" do
      let!(:clinician)    { create(:clinician) }
      let!(:address)      do 
        create(:clinician_address, :with_clinician_availability,
          clinician: clinician, postal_code: postal_code.zip_code, state: "AK")
      end
      let!(:care) { create(:type_of_care, facility_id: address.facility_id, clinician: clinician) }
      let!(:params) do
        { 
          age: 23, payment_type: "self_pay", utc_offset: "360", zip_codes: postal_code.zip_code, type_of_cares: care.type_of_care
        }
      end

      before do
        rsa_private = OpenSSL::PKey::RSA.generate 2048
        rsa_public = rsa_private.public_key

        allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
        @token = JWT.encode({
                              app_displayname: 'ABIE',
                              exp: (Time.now+200).strftime('%s').to_i
                            }, rsa_private, 'RS256')
      end

      it "filters clinicians by zip codes" do
        token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

        response_zipcodes = json_response["clinicians"][0]["addresses"].map { |address| address["postal_code"] }
        expect(response_zipcodes).to include(postal_code.zip_code)
      end

      it "filters clinicians by type of cares" do
        token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

        response_office_keys = json_response["clinicians"][0]["addresses"].map { |address| address["office_key"] }
        expect(response_office_keys).to include(care.amd_license_key)
      end

      it "filters clinicians by zip codes and type of cares" do
        token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

        clinician_addresses = json_response["clinicians"][0]["addresses"]
        response_zipcodes = clinician_addresses.map { |address| address["postal_code"] }
        response_facility_ids = clinician_addresses.map { |address| address["facility_id"] }

        expect(response_zipcodes).to include(address.postal_code)
        expect(response_facility_ids).to include(care.facility_id)
      end

      it "responds with unauthorized status without Authorization headers" do
        get "/abie/api/v2/clinicians", params: {}

        expect(response.status).to eq(401)
      end
    end

    context "when paying with insurance" do
      let!(:clinician) { create(:clinician) }
      let!(:address) do
        create(:clinician_address, :with_clinician_availability, clinician: clinician, postal_code: postal_code.zip_code, state: "AK")
      end
      let!(:insurance) { create(:insurance, name: "Aetna-Commercial", abie_intake_internal_display: true) }
      let!(:care) { create(:type_of_care, facility_id: address.facility_id, clinician: clinician) }
      let!(:params) do
        {
          age: 23, payment_type: "insurance", 'insurances[]': "Aetna-Commercial", utc_offset: "360",
          zip_codes: postal_code.zip_code, type_of_cares: care.type_of_care
        }
      end

      before do
        rsa_private = OpenSSL::PKey::RSA.generate 2048
        rsa_public = rsa_private.public_key

        allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
        @token = JWT.encode({
                              app_displayname: 'ABIE',
                              exp: (Time.now+200).strftime('%s').to_i
                            }, rsa_private, 'RS256')
      end

      it "responds with a clinician" do
        create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)
        token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

        expect(response.status).to eq(200)
        expect(json_response["meta"]["clinician_count"]).to eq(1)
      end
    end

    context "when there are no clincians with availability" do
      let!(:clinician)    { create(:clinician) }
      let!(:address)      do 
        create(:clinician_address, :with_clinician_availability,
          clinician: clinician, postal_code: postal_code.zip_code, state: "AK")
      end
      let!(:care) { create(:type_of_care, facility_id: address.facility_id, clinician: clinician) }
      let!(:params) do
        { 
          age: 23, payment_type: "self_pay", utc_offset: "360", zip_codes: postal_code.zip_code, type_of_cares: "Adult Psychiatry"
        }
      end

      before do
        rsa_private = OpenSSL::PKey::RSA.generate 2048
        rsa_public = rsa_private.public_key

        allow_any_instance_of(ApplicationController).to receive(:get_rsa_key).and_return(rsa_public)
        @token = JWT.encode({
                              app_displayname: 'ABIE',
                              exp: (Time.now+200).strftime('%s').to_i
                            }, rsa_private, 'RS256')
      end

      it "returns empty Clinician results when there is no match found with given filters" do  
        token_encoded_get("/abie/api/v2/clinicians", params: params, token: @token)

        expect(json_response["meta"]["clinician_count"]).to eq(0)
      end
    end

  end

  describe "GET /abie/api/v2/clinician/:id" do
    let(:clinician) { create(:clinician, :with_address) }
    let!(:type_of_care) { create(:type_of_care, clinician: clinician) }

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

    it "returns a 404 status for invalid clinician id" do
      invalid_id = clinician.id + 1
      token_encoded_get("/abie/api/v2/clinician/#{invalid_id}", params: {}, token: @token)
      expect(response).to have_http_status(:not_found)
    end

    it "responds with 200 when requested with valid clinician id" do
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", params: {}, token: @token)
      expect(response).to have_http_status(:ok)
    end

    describe "app_name filter is applied correct" do
      before do
        clinician2 = create(:clinician, :with_address)
        insurance = create(:insurance, name: "ABIE only", abie_intake_internal_display: true, obie_external_display: false)
        insurance2 = create(:insurance, name: "OBIE only", abie_intake_internal_display: false, obie_external_display: true)
        create(:facility_accepted_insurance, insurance: insurance,
              clinician_address: clinician.clinician_addresses.first, clinician: clinician)
        create(:facility_accepted_insurance, insurance: insurance2,
              clinician_address: clinician.clinician_addresses.first, clinician: clinician)
      end

      it "returns insurances with abie_intake_internal_display as true" do
        token_encoded_get("/abie/api/v2/clinician/#{clinician.id}?zip_codes=#{postal_code.zip_code}", params: {}, token: @token)

        expect(json_response["insurances"][0]["name"]).to eq "ABIE only"
      end

      it "does not return insurances with abie_intake_internal_display as false" do
        token_encoded_get("/abie/api/v2/clinician/#{clinician.id}?zip_codes=#{postal_code.zip_code}", params: {}, token: @token)

        insurance_names = json_response["insurances"].map { |insurance| insurance["name"] }
        expect(insurance_names).not_to include("OBIE only")
      end
    end

    it "responds with clinician data attributes for valid clinician" do
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", params: {}, token: @token)
      address = clinician.clinician_addresses.first

      clinician_availability = address.clinician_availabilities.first
      clinician_address_availability = {
        "appointment_end_time" => clinician_availability.appointment_end_time.strftime("%I:%M %p"),
        "appointment_start_time" => clinician_availability.appointment_start_time.strftime("%I:%M %p"),
        "available_date" => clinician_availability.available_date.strftime("%Y-%m-%d"),
        "clinician_availability_key" => clinician_availability.clinician_availability_key.to_s,
        "column_id" => clinician_availability.column_id,
        "facility_id" => clinician_availability.facility_id,
        "in_person_visit" => clinician_availability.in_person_visit,
        "license_key" => clinician_availability.license_key,
        "npi" => clinician_availability.npi,
        "profile_id" => clinician_availability.profile_id,
        "provider_id" => clinician_availability.provider_id,
        "rank_most_available" => clinician_availability.rank_most_available,
        "rank_soonest_available" => clinician_availability.rank_soonest_available,
        "reason" => clinician_availability.reason,
        "type_of_care" => clinician_availability.type_of_care,
        "virtual_or_video_visit" => clinician_availability.virtual_or_video_visit,
      }
      facility_insurances = address.insurances.where.not(facility_accepted_insurances: { supervisors_name: nil }).pluck(:id, :name).uniq
      keys = %w[id name]
      supervised_insurances = facility_insurances.map { |v| keys.zip v }.map(&:to_h)

      insurances = address.insurances.pluck(:id, :name).uniq
      keys = %w[id name]
      insurances = insurances.map { |v| keys.zip v }.map(&:to_h)

      supervised_insurances = address.insurances.where.not(facility_accepted_insurances: { supervisors_name: nil }).pluck(:id, :name).uniq
      keys = %w[id name]
      supervised_insurances = supervised_insurances.map { |v| keys.zip v }.map(&:to_h)
      address_data = ActiveSupport::HashWithIndifferentAccess.new(
        "address_code" => address.address_code,
        "address_line1" => address.address_line1,
        "address_line2" => address.address_line2,
        "apt_suite" => address.apt_suite,
        "area_code" => address.area_code,
        "city" => address.city,
        "country_code" => address.country_code,
        "facility_id" => address.facility_id,
        "facility_name" => address.facility_name,
        "distance_in_miles" => nil,
        "clinician_availabilities" => [clinician_address_availability],
        "id" => address.id,
        "office_key" => address.office_key,
        "postal_code" => address.postal_code,
        "primary_location" => address.primary_location,
        "state" => address.state,
        insurances: insurances,
        supervised_insurances: supervised_insurances,
        video_visit: address.clinician.video_visit,
        in_office: address.clinician.in_office,
        rank_most_available: address.clinician_availabilities.first&.rank_most_available,
        rank_soonest_available: address.clinician_availabilities.first&.rank_soonest_available
      )
      type_of_care = clinician.type_of_cares.first.type_of_care
      education = clinician.educations.first.nil? ? [] : clinician.educations.first
      insurance = clinician.insurances.first.nil? ? [] : clinician.insurances.first
      supervisors = clinician.facility_accepted_insurances.pluck(:supervisors_name, :license_number)
      supervisory_keys = %w[full_name license_number]
      supervisory_data = supervisors.map { |e| supervisory_keys.zip(e).to_h }
      supervisor_data = {
        supervised_clinician: clinician.supervised_clinician,
        supervisors: supervisory_data
      }

      clinician_data = ActiveSupport::HashWithIndifferentAccess.new(
        id: clinician.id,
        first_name: clinician.first_name,
        last_name: clinician.last_name,
        type: clinician.mapped_clinician_type,
        about: clinician.about_the_provider,
        in_office: clinician.in_office,
        virtual_visit: clinician.video_visit,
        manages_medication: clinician.manages_medication,
        ages_accepted: clinician.ages_accepted,
        credentials: clinician.license_type,
        languages_spoken: clinician.languages.pluck(:name),
        expertises: clinician.expertises.pluck(:name),
        gender: clinician.gender,
        educations: education,
        # facility_location: [address_data],
        insurances: insurance,
        interventions: clinician.interventions.pluck(:name),
        license_key: clinician.license_key,
        photo: clinician.photo,
        populations: clinician.populations.pluck(:name),
        pronouns: clinician.pronouns,
        provider_id: clinician.provider_id,
        telehealth_url: clinician.telehealth_url,
        type_of_cares: [type_of_care],
        supervisor_data: supervisor_data
      )

      expect(json_response).to include(clinician_data)
      expect(json_response["facility_location"].first).to include(address_data)
    end

    it "responds with clinician data attributes for valid clinician and distance_in_miles" do
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}?zip_codes=#{postal_code.zip_code}", params: {}, token: @token)

      clinician_data = ActiveSupport::HashWithIndifferentAccess.new(
        id: clinician.id,
        first_name: clinician.first_name,
        last_name: clinician.last_name,
        type: clinician.mapped_clinician_type,
        about: clinician.about_the_provider,
        in_office: clinician.in_office,
        virtual_visit: clinician.video_visit,
        manages_medication: clinician.manages_medication,
        ages_accepted: clinician.ages_accepted,
        credentials: clinician.license_type,
        languages_spoken: clinician.languages.pluck(:name),
        expertises: clinician.expertises.pluck(:name)
      )
      address = clinician.clinician_addresses.first
      address_data = ActiveSupport::HashWithIndifferentAccess.new(
        "address_code" => address.address_code,
        "address_line1" => address.address_line1,
        "address_line2" => address.address_line2,
        "apt_suite" => address.apt_suite,
        "area_code" => address.area_code,
        "city" => address.city,
        "country_code" => address.country_code,
        "facility_id" => address.facility_id,
        "facility_name" => address.facility_name,
        "distance_in_miles" => 2754.35
      )

      expect(json_response).to include(clinician_data)
      expect(json_response["facility_location"].first).to include(address_data)
    end

    it "return clinician with license key at root level" do
      clinician = create(:clinician, :with_address, license_key: "996078")
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", params: {}, token: @token)

      expect(json_response["license_key"]).to eq clinician.license_key
    end

    it "with other_providers param returns additional clinicians" do
      clinician = create(:clinician)
      clinician_address = create(:clinician_address, clinician: clinician)

      insurance = create(:insurance)
      facility = create(:facility_accepted_insurance, clinician: clinician, insurance: insurance, clinician_address: clinician_address)
      clinician_address.facility_id = facility.id
      clinician_address.save!
      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", params: { other_providers: true }, token: @token)
      other_clinicians = Clinician.other_providers(clinician, facility)
      additional_providers = JSON.parse(ActiveModel::Serializer::CollectionSerializer.new(other_clinicians, serializer: OtherClinicianDetailsSerializer).to_json)
      expect(json_response["clinicians"]).to eq additional_providers
    end

    # This is the issue that was found on the 23.5.2 release RC, we still need to add the all to the clinician_addresses from the clinician relation
    it "with other_providers param returns additional clinicians with same license_key" do
      license_key = "999555"
      clinician = create(:clinician, :with_address, license_key: license_key)
      clinician_address = create(:clinician_address, office_key: license_key, clinician: clinician)

      clinician_with_same_license_key = create(:clinician, license_key: license_key)
      create(:clinician_address, office_key: license_key, clinician: clinician_with_same_license_key)
      insurance = create(:insurance)
      facility = create(:facility_accepted_insurance, clinician: clinician, insurance: insurance, clinician_address: clinician_address)
      clinician_address.facility_id = facility.id
      clinician_address.save!

      token_encoded_get("/abie/api/v2/clinician/#{clinician.id}", params: { other_providers: true }, token: @token)

      facilities = clinician.clinician_addresses.all.map(&:facility_id)
      other_clinicians = Clinician.other_providers(clinician, facilities)
      additional_providers = JSON.parse(ActiveModel::Serializer::CollectionSerializer.new(other_clinicians, serializer: OtherClinicianDetailsSerializer).to_json)
      expect(json_response["clinicians"]).to eq additional_providers
    end
  end  
end
