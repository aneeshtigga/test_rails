require "rails_helper"

RSpec.describe "Clinicians", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday

  before do
    Clinician.destroy_all

    create(
      :postal_code,
      zip_code: "12345",
      city:     "Fake City",
      state:    "DC"
    )

    create(
      :postal_code,
      zip_code: "44122",
      city:     "Beachwood",
      state:    "OH"
    )

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

    @postal_code = create(:postal_code, zip_code: "30301")
    travel_to stub_time
  end

  after do
    travel_back
  end

  describe "GET /api/v1/clinicians" do
    let!(:clinician) { create(:clinician, :with_address) }

    it "will provide all the Clinicians when no filters were applies" do
      token_encoded_get("/api/v1/clinicians", params: {}, token: @token)

      expect(Clinician.count).to eq(json_response["meta"]["clinician_count"])
    end

    it "will filter Clinicians by languages" do
      create(:clinician_language, clinician: clinician)
      languages = %w[english russian]

      params = { search: { languages: languages } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      response_languages = json_response["clinicians"][0]["languages"].map { |language| language["name"].downcase }
      expect(languages).to include(*response_languages)
    end

    it "will filter clinician by expertises" do
      create(:clinician_expertise, clinician: clinician)

      params = { search: { expertises: "MD" } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      response_expertises = json_response["clinicians"][0]["expertises"].map { |expertise| expertise["name"] }

      expect(response_expertises).to include("MD")
    end

    it "will filter clinician by concerns" do
      concern = create(:concern, name: "MD")
      create(:clinician_concern, clinician: clinician, concern: concern)

      params = { search: { concerns: "MD" } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      response_concerns = json_response["clinicians"][0]["concerns"].map { |concern| concern["name"] }

      expect(response_concerns).to include("MD")
    end

    it "will filter clinicians by clinician types" do
      params = { search: { clinician_types: "Adult Therapy" } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      response_clinician_type = json_response["clinicians"][0]["clinician_type"]
      expect(response_clinician_type).to include("Psychotherapist")
    end

    it "will filter clinicians by zip codes" do
      zip_code = "30301"
      address = create(:clinician_address, clinician: clinician, postal_code: zip_code)

      params = { search: { zip_codes: zip_code, app_name: "obie" } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)
      response_zipcodes = json_response["clinicians"][0]["addresses"].map { |address| address["postal_code"] }
      expect(response_zipcodes).to include(zip_code)
    end

    it "will filter clinicians by type of cares" do
      address = create(:clinician_address, clinician: clinician)
      clinician = address.clinician
      care = create(:type_of_care, facility_id: address.facility_id, clinician: clinician)

      params = { search: { type_of_cares: care.type_of_care, app_name: "obie" } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      response_office_keys = json_response["clinicians"][0]["addresses"].map { |address| address["office_key"] }
      expect(response_office_keys).to include(care.amd_license_key)
    end

    it "will filter clinicians by languages and expertises" do
      language = create(:clinician_language, clinician: clinician)
      create(:clinician_expertise, clinician_id: language.clinician_id)
      languages = %w[english russian]

      params = { search: { languages: languages, expertises: "MD", app_name: "obie" } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      clinician_results = json_response["clinicians"].first
      response_expertises = clinician_results["expertises"].map { |expertise| expertise["name"] }
      response_languages = clinician_results["languages"].map { |language| language["name"].downcase }

      expect(languages).to include(*response_languages)
      expect(response_expertises).to include("MD")
    end

    it "will filter clinicians by clinician types and zip code" do
      zip_code = "30301"
      address = create(:clinician_address, clinician: clinician, postal_code: zip_code)

      params = {
        search: {
          clinician_types: "Adult Therapy",
          zip_codes: zip_code,
          app_name: "obie"
        }
      }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      clinician_results = json_response["clinicians"].first
      response_clinician_type = clinician_results["clinician_type"]
      response_zipcodes = clinician_results["addresses"].map { |address| address["postal_code"] }

      expect(response_clinician_type).to include("Psychotherapist")
      expect(response_zipcodes).to include(zip_code)
    end

    it "will filter clinicians by zip codes and type of cares" do
      address = create(:clinician_address, clinician: create(:clinician, :with_address))
      clinician = address.clinician
      care = create(:type_of_care, facility_id: address.facility_id, clinician: clinician)

      params = { search: { type_of_cares: care.type_of_care, zip_codes: address.postal_code, app_name: "obie" } }
      token_encoded_get("/api/v1/clinicians", params: params, token: @token)

      clinician_addresses = json_response["clinicians"][0]["addresses"]
      response_zipcodes = clinician_addresses.map { |address| address["postal_code"] }
      response_facility_ids = clinician_addresses.map { |address| address["facility_id"] }

      expect(response_zipcodes).to include(address.postal_code)
      expect(response_facility_ids).to include(care.facility_id)
    end

    it "will respond with unauthorized status without Authorization headers" do
      get "/api/v1/clinicians", params: {}

      expect(response.status).to eq(401)
    end

    it "will filter clinicians with firstname as part of search term" do
      skip "Bad Test Data - need to add the zip_codes parameter"

      create(:clinician, :with_address, first_name: "John", last_name: "Smith")
      create(:clinician, :with_address, first_name: "David", last_name: "wilson")
      token_encoded_get("/api/v1/clinicians", params: { search: { search_term: "david"} }, token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["clinicians"][0]["first_name"].downcase).to eq(request["search"]["search_term"])
    end

    it "will filter clinicians with lastname as part of search term" do
      skip "Bad Test Data - need to add the zip_codes parameter"

      create(:clinician, :with_address, first_name: "John", last_name: "Smith")
      create(:clinician, :with_address, first_name: "David", last_name: "wilson")
      create(:postal_code, zip_code: 90210)

      token_encoded_get("/api/v1/clinicians", params: { search: { search_term: "wilson", zip_codes: 90210 } }, token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["clinicians"][0]["last_name"].downcase).to eq(request["search"]["search_term"])
    end

    it "will filter clinicians with name concatenated with firstname and lastname" do
      skip "Bad Test Data - need to add the zip_codes parameter"

      zip_code  = 90210
      state     = 'CA'
      create(:postal_code, zip_code: zip_code, state: state)
      ca = create(:clinician_address, postal_code: 90210, state: state)
      create(:clinician, clinician_addresses: ca, first_name: "John", last_name: "Smith")
      create(:clinician, clinician_addresses: ca, first_name: "David", last_name: "wilson")

      token_encoded_get("/api/v1/clinicians", params: { search: { search_term: "david wilson", zip_codes: 90210 } }, token: @token)

      response_clinician = json_response["clinicians"][0]
      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect("#{response_clinician['first_name'].downcase} #{response_clinician['last_name'].downcase}").to eq(request["search"]["search_term"])
    end

    it "returns clinicians with the filtered location" do
      matching_clinician_address = create(:clinician_address, clinician: clinician, facility_name: "matched")
      not_matching_clinician_address = create(:clinician_address, clinician: clinician, facility_name: "not_matched")

      token_encoded_get("/api/v1/clinicians", params: { search: { location_names: ["matched"] } }, token: @token)

      expect(json_response["clinicians"].count).to eq(1)
      expect(json_response["clinicians"].first["addresses"].first["facility_name"]).to eq("matched")
      expect(json_response["clinicians"].first["license_type"]).to eq("MD")
    end

    it "returns empty Clinician results when there is no match found with given filters" do
      create(:clinician, :with_address)

      token_encoded_get("/api/v1/clinicians",
                        params: { search: { zip_codes: "12345", type_of_cares: "Adult Psychiatry" } }, token: @token)

      expect(json_response["meta"]["clinician_count"]).to eq(0)
    end

    context "Payment type is self-pay" do
      let(:zip_code) { "44122" }
      let(:clinician) { create(:clinician, :with_address, video_visit: true) }
      let!(:address) { create(:clinician_address, clinician: clinician, postal_code: zip_code) }
      let!(:type_of_care) { create(:type_of_care, type_of_care: "Child Neuro/Psych Testing", clinician: clinician) }

      it "returns clinicians when clinicians when payment is self-pay and insurances is specified" do
        token_encoded_get("/api/v1/clinicians",
                          params: { search: { zip_codes: zip_code, type_of_cares: "Child Neuro/Psych Testing", modality: "video_visit", payment_type: "self_pay", insurances: "undefined" } }, token: @token)

        expect(json_response["meta"]["clinician_count"]).to eq 1
      end
    end


    describe "Searching nearby zipcodes" do
      let(:this_license) do
        create(
          :license_key,
          key: 9995456
        )
      end

      #################################
      let(:current_zipcode) { "45999" }

      let(:current_postal_data) do
        create(
          :postal_code,
          zip_code:   current_zipcode,
          latitude:   39.089,
          longitude:  -84.51,
          zip_codes_by_radius: { '60_mile': ["45354"] }
        )
      end

      let(:current_clinician) do
        create(
          :clinician,
          first_name:   'first',
          last_name:    'of_two',
          cbo:          123456,
          license_key:  this_license.key,
          provider_id:  111
        )
      end

      let(:current_address) do
        create(
          :clinician_address,
          :with_clinician_availability,
          clinician:    current_clinician,
          cbo:          current_clinician.cbo,
          office_key:   current_clinician.license_key,
          provider_id:  current_clinician.provider_id,
          postal_code:  current_postal_data.zip_code,
          latitude:     39.089,
          longitude:    -84.51,
          )
      end

      ##################################
      let(:near_by_zipcode) { "45354" }

      let(:near_by_clinician) do
        create(
          :clinician,
          first_name:   'dos',
          last_name:    'echees',
          cbo:          123456,
          license_key:  this_license.key,
          provider_id:  222
        )
      end

      let(:near_by_postal_data) do
        create(
          :postal_code,
          zip_code:   near_by_zipcode,
          latitude:   39.91,
          longitude:  -84.399,
          zip_codes_by_radius: { '60_mile': ["45894"] }
        )
      end

      let(:near_by_address) do
        create(
          :clinician_address,
          :with_clinician_availability,
          clinician:    near_by_clinician,
          cbo:          near_by_clinician.cbo,
          office_key:   near_by_clinician.license_key,
          provider_id:  near_by_clinician.provider_id,
          postal_code:  near_by_postal_data.zip_code,
          latitude:     39.91,
          longitude:    -84.399,
          )
      end

      it "returns results for zipcodes within 60 miles if current zipcode have no results" do
        skip "Bad Test Data - clinician_availability???"

        Clinician.destroy_all
        ClinicianAddress.destroy_all
        ClinicianAvailability.destroy_all
        PostalCode.destroy_all

        near_by_zipcode
        near_by_postal_data
        near_by_clinician
        near_by_address

        current_zipcode
        current_postal_data
        current_clinician
        current_address

        params = { search: { zip_codes: current_zipcode, distance: 60 } }
        token_encoded_get("/api/v1/clinicians", params: params, token: @token)

        expect(json_response["clinicians"].size).to eq(1)
        expect(json_response["clinicians"][0]["addresses"][0]["postal_code"]).to eq(near_by_zipcode)
      end

      it "returns clinicians of both current and near_by_zipcode if exists" do
        skip "Bad Test Data - clinician_availability???"

        near_by_address
        current_address

        current_ca  = Array(current_address.clinician_availabilities).first
        current_ca.update(
          available_date:         current_ca.available_date          + 1.week,
          appointment_start_time: current_ca.appointment_start_time  + 1.week,
          appointment_end_time:   current_ca.appointment_end_time    + 1.week
        )

        params = { search: { distance: 60, zip_codes: current_zipcode } }
        token_encoded_get("/api/v1/clinicians", params: params, token: @token)

        expect(json_response["clinicians"].size).to eq(2)
        expect(json_response["clinicians"][1]["addresses"][0]["postal_code"]).to eq(current_zipcode)
        expect(json_response["clinicians"][0]["addresses"][0]["postal_code"]).to eq(near_by_zipcode)
      end
    end

    describe "search by availabilities" do
      context "availability_by_time" do
        let!(:address) { clinician.clinician_addresses.first }

        it "should return clinician_addresses by availability time" do
          date_time = DateTime.now.utc.change({ hour: 19, min: 00, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["after_12_PM"], utc_offset: "300" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to_not be_empty
        end

        it "should return clinician_addresses by availability after time considering offset" do
          date_time = DateTime.now.utc.change({ hour: 11, min: 00, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["after_12_PM"], utc_offset: "-60" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to_not be_empty
        end

        it "should not return clinician_addresses if availability after time out of filter range" do
          date_time = DateTime.now.utc.change({ hour: 10, min: 00, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["after_12_PM"], utc_offset: "-60" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to be_empty
        end

        it "should return clinician_addresses by availability before time considering offset" do
          date_time = DateTime.now.utc.change({ hour: 8, min: 00, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["before_10_AM"], utc_offset: "-60" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to_not be_empty
        end

        it "should not return clinician_addresses if availability before time out of filter range" do
          date_time = DateTime.now.utc.change({ hour: 10, min: 00, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["before_10_AM"], utc_offset: "-60" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to be_empty
        end

        it "should not return clinician_addresses out of filter time" do
          date_time = DateTime.now.utc.change({ hour: 12, min: 0, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["before_10_AM"], utc_offset: 0} }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to be_empty
        end

        it "should return clinician_addresses after filter time" do
          date_time = DateTime.now.utc.change({ hour: 14, min: 0, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["after_12_PM"], utc_offset: 0 } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to_not be_empty
          expect(json_response["clinicians"].map { |clinician| clinician["id"] }).to include(address.clinician_id)
        end

        it "should return clinician_addresses by after and before filter" do
          date_time = DateTime.now.utc.change({ hour: 14, min: 0, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: %w[after_12_PM before_3_PM], utc_offset: "60" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to_not be_empty
          expect(json_response["clinicians"].map { |clinician| clinician["id"] }).to include(address.clinician_id)
        end

        it "should not return clinician_addresses with new patient availability even it falls under available filter" do
          ClinicianAvailability.last.update(is_fu: false)
          date_time = DateTime.now.utc.change({ hour: 14, min: 0, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: %w[after_12_PM before_3_PM], utc_offset: "60", patient_status: "existing" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to be_empty
        end

        it "should not return clinician_addresses out of applied filter" do
          date_time = DateTime.now.utc.change({ hour: 17, min: 0, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: %w[after_12_PM before_3_PM], utc_offset: "60" } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to be_empty
        end

        it "should not return clinician_addresses before filter time" do
          date_time = DateTime.now.utc.change({ hour: 11, min: 0, sec: 0 }) + 2.days
          address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
          params = { search: { availability_filter: ["after_12_PM"], utc_offset: 0 } }
          token_encoded_get("/api/v1/clinicians", params: params, token: @token)

          expect(json_response["clinicians"]).to be_empty
        end

        context "return filtered results by clients offset" do
          it "should return 9PM availability under after_12_pm filter without offset" do
            date_time = DateTime.now.utc.change({ hour: 21, min: 0, sec: 0 }) + 2.days
            address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
            params = { search: { availability_filter: ["after_12_PM"], utc_offset: "0" } }
            token_encoded_get("/api/v1/clinicians", params: params, token: @token)
            address.clinician_availabilities.reload

            expect(json_response["clinicians"].size).to eq(1)
            expect(json_response["clinicians"][0]["clinician_availabilities"][0]["clinician_availability_key"]).to eq(address.clinician_availabilities.first.clinician_availability_key.to_s)
          end

          it "should return 9PM availability under before_12_pm filter with offset" do
            date_time = DateTime.now.utc.change({ hour: 21, min: 0, sec: 0 }) + 2.days
            address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
            params = { search: { availability_filter: ["before_12_PM"], utc_offset: "300" } }
            token_encoded_get("/api/v1/clinicians", params: params, token: @token)
            address.clinician_availabilities.reload

            expect(json_response["clinicians"]).to be_empty
          end

          it "should return 9PM availability under after_12_PM filter with offset of 300 minutes" do
            date_time = DateTime.now.utc.change({ hour: 21, min: 0, sec: 0 }) + 2.days
            address.clinician_availabilities.first.update!(appointment_start_time: date_time.utc)
            params = { search: { availability_filter: ["after_12_PM"], utc_offset: "300" } }
            token_encoded_get("/api/v1/clinicians", params: params, token: @token)
            address.clinician_availabilities.reload

            expect(json_response["clinicians"].size).to eq(1)
            expect(json_response["clinicians"][0]["clinician_availabilities"][0]["clinician_availability_key"]).to eq(address.clinician_availabilities.first.clinician_availability_key.to_s)
          end
        end
      end
    end

    describe "search by modalities" do
      let!(:address) { create(:clinician_address) }
      let!(:availability) do
        create(:clinician_availability, facility_id: address.facility_id, license_key: address.office_key,
               provider_id: address.provider_id)
      end
      let!(:clinician) { create(:clinician, first_name: "Darwin", provider_id: 1729, license_key: 45_678) }
      let!(:address2) { create(:clinician_address, facility_id: 123, office_key: 45_678, provider_id: 1729) }
      let(:availability2) { create(:clinician_availability, facility_id: 123, license_key: 45_678, provider_id: 1729) }

      it "will filter clinicians with modality video_visit only" do
        availability.update(virtual_or_video_visit: 1, in_person_visit: 0,
                            appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "video_visit" } }, token: @token)

        expect(json_response["meta"]["clinician_count"]).to eq 1
        expect(json_response["clinicians"][0]["id"]).to eq(address.clinician_id)
      end

      it "will filter clinicians with modality video-visit as video_visit only" do
        availability.update(virtual_or_video_visit: 1, in_person_visit: 0,
                            appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "video-visit" } }, token: @token)

        expect(json_response["meta"]["clinician_count"]).to eq 1
        expect(json_response["clinicians"][0]["id"]).to eq(address.clinician_id)
      end

      it "will filter clinicians with modality in_office only" do
        availability.update(virtual_or_video_visit: 0, in_person_visit: 1,
                            appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "in_office" } }, token: @token)

        expect(json_response["meta"]["clinician_count"]).to eq 1
        expect(json_response["clinicians"][0]["id"]).to eq(address.clinician_id)
      end

      it "will filter clinicians with modality in_office and video_visit both" do
        availability.update(virtual_or_video_visit: 1, in_person_visit: 1,
                            appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "both" } }, token: @token)

        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["in_person_visit"]).to eq(1)
        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["virtual_or_video_visit"]).to eq(1)
      end

      it "will filter clinicians with modality in-office as in_office" do
        availability.update(virtual_or_video_visit: 1, in_person_visit: 1,
                            appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "in-office" } },
                          token: @token)

        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["in_person_visit"]).to eq(1)
        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["virtual_or_video_visit"]).to eq(0)
      end

      it "will filter clinicians with modality in_office" do
        availability.update(virtual_or_video_visit: 1, in_person_visit: 1,
                            appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "in_office" } },
                          token: @token)

        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["in_person_visit"]).to eq(1)
        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["virtual_or_video_visit"]).to eq(0)
      end

      it "will filter clinicians with modality video_visit" do
        availability.update(virtual_or_video_visit: 1, in_person_visit: 1,
                            appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "video_visit" } },
                          token: @token)

        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["in_person_visit"]).to eq(0)
        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["virtual_or_video_visit"]).to eq(1)
      end

      it "returns the clinicians under active office keys" do
        availability.update(virtual_or_video_visit: 1, in_person_visit: 1, appointment_start_time: Time.now.utc + 7.days)
        token_encoded_get("/api/v1/clinicians", params: { search: { modality: "video_visit" } },
                          token: @token)

        expect(json_response["clinicians"].size).to eq(1)
        expect(json_response["clinicians"][0]["clinician_availabilities"][0]["virtual_or_video_visit"]).to eq(1)
      end
    end
  end

  describe "GET /api/v1/clinician/:id" do
    let(:clinician) { create(:clinician, :with_address) }
    let!(:type_of_care) { create(:type_of_care, clinician: clinician) }

    it "returns a 401 status if jwt is not passed" do
      token_encoded_get("/api/v1/clinician/#{clinician.id}", params: { app_name: 'obie' }, token: nil)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns a 404 status for invalid clinician id" do
      invalid_id = clinician.id + 1
      token_encoded_get("/api/v1/clinician/#{invalid_id}", params: { app_name: 'obie' }, token: @token)
      expect(response).to have_http_status(:not_found)
    end

    it "responds with 200 when requested with valid clinician id" do
      token_encoded_get("/api/v1/clinician/#{clinician.id}", params: { app_name: 'obie' }, token: @token)
      expect(response).to have_http_status(:ok)
    end

    it "responds with error message when app_name is not passed" do
      token_encoded_get("/api/v1/clinician/#{clinician.id}", params: {}, token: @token)
      expect(response).to have_http_status(:bad_request)   
      expect(json_response["message"]).to eq("app_name is required")   
    end

    describe "app_name filter" do
      before do
        clinician2 = create(:clinician, :with_address)
        insurance = create(:insurance, name: "ABIE only", abie_intake_internal_display: true, obie_external_display: false)
        insurance2 = create(:insurance, name: "OBIE only", abie_intake_internal_display: false, obie_external_display: true)
        create(:facility_accepted_insurance, insurance: insurance,
              clinician_address: clinician.clinician_addresses.first, clinician: clinician)
        create(:facility_accepted_insurance, insurance: insurance2,
              clinician_address: clinician.clinician_addresses.first, clinician: clinician)
      end

      context "when app_name is abie" do
        it "returns insurances with abie_intake_internal_display as true" do
          token_encoded_get("/api/v1/clinician/#{clinician.id}?zip_codes=#{@postal_code.zip_code}", params: { app_name: 'abie' }, token: @token2)

          expect(json_response["insurances"][0]["name"]).to eq "ABIE only"
        end

        it "does not return insurances with abie_intake_internal_display as false" do
          token_encoded_get("/api/v1/clinician/#{clinician.id}?zip_codes=#{@postal_code.zip_code}", params: { app_name: 'abie' }, token: @token2)

          insurance_names = json_response["insurances"].map { |insurance| insurance["name"] }
          expect(insurance_names).not_to include("OBIE only")
        end
      end

      context "when app_name is obie" do
        it "returns insurances with obie_external_display as true" do
          token_encoded_get("/api/v1/clinician/#{clinician.id}?zip_codes=#{@postal_code.zip_code}", params: { app_name: 'obie' }, token: @token)

          expect(json_response["insurances"][0]["name"]).to eq "OBIE only"
        end

        it "does not return insurances with obie_external_display as false" do
          token_encoded_get("/api/v1/clinician/#{clinician.id}?zip_codes=#{@postal_code.zip_code}", params: { app_name: 'obie' }, token: @token)

          insurance_names = json_response["insurances"].map { |insurance| insurance["name"] }
          expect(insurance_names).not_to include("ABIE only")
        end
      end
    end

    it "responds with clinician data attributes for valid clinician" do
      token_encoded_get("/api/v1/clinician/#{clinician.id}", params: { app_name: 'obie' }, token: @token)
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
      token_encoded_get("/api/v1/clinician/#{clinician.id}?zip_codes=#{@postal_code.zip_code}", params: { app_name: 'obie' }, token: @token)

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

    it "will filter clinicians with pronouns as 'She/her'" do
      create(:clinician, :with_address, pronouns: "His/He/Him")
      create(:clinician, :with_address, pronouns: "Her/She")
      token_encoded_get("/api/v1/clinicians", params: { search: { pronouns: "Her/She" } }, token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq 1
    end

    it "will filter clinicians with pronouns 'Them/they' and 'She/her' both" do
      create(:clinician, :with_address, pronouns: "They/Them")
      create(:clinician, :with_address, pronouns: "Her/She")
      pronouns = %w[them She]
      clinician_pronouns = Array(pronouns)
      token_encoded_get("/api/v1/clinicians", params: { search: { pronouns: pronouns } }, token: @token)

      expect(json_response["meta"]["clinician_count"]).to eq Clinician.with_pronouns(clinician_pronouns).count
    end

    it "returns clinicians with payment type insurance" do
      clinician = create(:clinician, :with_address)
      clinician_2 = create(:clinician)
      insurance = create(:insurance, name: "Health")
      create(:facility_accepted_insurance, insurance: insurance,
             clinician_address: clinician.clinician_addresses.first, clinician: clinician)

      token_encoded_get("/api/v1/clinicians", params: { search: { payment_type: "insurance", insurances: [insurance.name], app_name: "obie" } },
                        token: @token)
      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq 1
    end

    it "returns clinicians with payment type insurance" do
      clinician_2 = create(:clinician, :with_address)
      insurance = create(:insurance, name: "Health")
      create(:facility_accepted_insurance, insurance: insurance, clinician_address: clinician.clinician_addresses.last,
             clinician: clinician)

      token_encoded_get("/api/v1/clinicians", params: { search: { payment_type: "insurance", insurances: "Health", app_name: "obie" } },
                        token: @token)
      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq 1
    end

    it "returns clinicians with insurances" do
      clinician_2 = create(:clinician, :with_address)
      insurance = create(:insurance, name: "Health")
      insurance_2 = create(:insurance, name: "Health2")
      create(:facility_accepted_insurance, insurance: insurance,
             clinician_address: clinician.clinician_addresses.first, clinician: clinician)
      create(:facility_accepted_insurance, insurance: insurance_2,
             clinician_address: clinician_2.clinician_addresses.first, clinician: clinician_2)

      token_encoded_get("/api/v1/clinicians", params: { search: { insurances: "Health", payment_type: "insurance", app_name: "obie" } },
                        token: @token)
      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq 1
    end

    context "when insurances are disabled for the app" do
      it "returns no clinicians" do
        clinician_2 = create(:clinician, :with_address)
        insurance = create(:insurance, name: "Health", obie_external_display: false)
        insurance_2 = create(:insurance, name: "Health2", obie_external_display: false)
        create(:facility_accepted_insurance, insurance: insurance,
              clinician_address: clinician.clinician_addresses.first, clinician: clinician)
        create(:facility_accepted_insurance, insurance: insurance_2,
              clinician_address: clinician_2.clinician_addresses.first, clinician: clinician_2)

        token_encoded_get("/api/v1/clinicians", params: { search: { insurances: "Health", payment_type: "insurance" } },
                          token: @token)
        expect(json_response["meta"]["clinician_count"]).to be 0
      end
    end

    it "returns clinicians with multiple insurances" do
      clinician_2 = create(:clinician, :with_address)
      insurance = create(:insurance, name: "Health")
      insurance_2 = create(:insurance, name: "Health2")

      create(:facility_accepted_insurance, insurance: insurance,
             clinician_address: clinician.clinician_addresses.first, clinician: clinician)

      create(:facility_accepted_insurance, insurance: insurance_2,
             clinician_address: clinician_2.clinician_addresses.first, clinician: clinician_2)

      token_encoded_get("/api/v1/clinicians", params: {
        search: { insurances: %w[Health Health2], payment_type: "insurance", app_name: "obie" } 
      },
                        token: @token)

      expect(json_response["meta"]["clinician_count"]).to eq Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq 2
    end

    it "return no clinicians with insurances that is not present" do
      clinician_2 = create(:clinician, :with_address)
      insurance = create(:insurance, name: "Health")
      insurance_2 = create(:insurance, name: "Health2")
      create(:facility_accepted_insurance, insurance: insurance,
             clinician_address: clinician.clinician_addresses.first, clinician: clinician)
      create(:facility_accepted_insurance, insurance: insurance_2,
             clinician_address: clinician_2.clinician_addresses.first, clinician: clinician_2)

      token_encoded_get("/api/v1/clinicians", params: { 
        search: { insurances: "Health3", payment_type: "insurance", app_name: "obie" }
      }, token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["clinicians"]).to be_empty
    end

    it "return all clinicians with all clinicians in accepted ages in range" do
      clinician = create(:clinician, :with_address, ages_accepted: "4-12")
      token_encoded_get("/api/v1/clinicians", params: { search: { age: 6 } },
                        token: @token)

      expect(json_response["meta"]["clinician_count"]).to eq Clinician.count
    end

    it "return clinicians with ages accepted in range" do
      clinician = create(:clinician, :with_address, ages_accepted: "4-12")
      clinician_2 = create(:clinician, :with_address, ages_accepted: "4-10")
      age = 11
      token_encoded_get("/api/v1/clinicians", params: { search: { age: age } },
                        token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq Clinician.with_accepted_ages(age).count
    end

    it "return no clinicians with ages accepted not in range" do
      clinician = create(:clinician, :with_address, ages_accepted: "4-12")
      clinician_2 = create(:clinician, :with_address, ages_accepted: "4-10")
      age = 201
      token_encoded_get("/api/v1/clinicians", params: { search: { age: age } },
                        token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["clinicians"]).to be_empty
    end

    it "return clinicians with credentials 'MS'" do
      clinician = create(:clinician, :with_address, license_type: "MD")
      license_type = create(:license_type, name: "MS")
      create(:clinician_license_type, clinician: clinician, license_type: license_type)
      clinician_2 = create(:clinician, :with_address, license_type: "MS")
      token_encoded_get("/api/v1/clinicians", params: { search: { credentials: "MS" } },
                        token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq 1
    end

    it "return clinicians with special cases 'Recently discharged from a psychiatric hospital'" do
      clinician_1 = create(:clinician, :with_address)
      clinician_2 = create(:clinician, :with_address)
      special_case_1 = create(:special_case, name: "Recently discharged from a psychiatric hospital")
      special_case_2 = create(:special_case)
      create(:clinician_special_case, special_case: special_case_1, clinician: clinician_1)
      create(:clinician_special_case, special_case: special_case_2,  clinician: clinician_2)
      token_encoded_get("/api/v1/clinicians", params: { search: { special_cases: ["Recently discharged from a psychiatric hospital"] } },
                        token: @token)
      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["meta"]["clinician_count"]).to eq 1
    end

    it "return clinicians with credentials 'MD' and 'MS'" do
      clinician = create(:clinician, :with_address, license_type: "MD")
      license_type1 = create(:license_type, name: "MS")
      create(:clinician_license_type, clinician: clinician, license_type: license_type1)
      clinician_2 = create(:clinician, :with_address, license_type: "MS")
      license_type2 = create(:license_type, name: "MD")
      create(:clinician_license_type, clinician: clinician_2, license_type: license_type2)
      credentials = %w[MD MS]
      token_encoded_get("/api/v1/clinicians", params: { search: { credentials: [credentials] } },
                        token: @token)
      expect(json_response["meta"]["clinician_count"]).to eq Clinician.with_license_types(credentials).count
    end

    it "return clinician with license key at root level" do
      clinician = create(:clinician, :with_address, license_key: "996078")
      license_key1 = create(:license_key, key: 996078)
      token_encoded_get("/api/v1/clinician/#{clinician.id}", params: { app_name: "obie" }, token: @token)

      expect(json_response["license_key"]).to eq clinician.license_key
    end

    it "return no clinicians with credentials 'MD'" do
      clinician = create(:clinician, :with_address, license_type: "MS")
      license_type1 = create(:license_type, name: "MS")
      create(:clinician_license_type, clinician: clinician, license_type: license_type1)
      clinician_2 = create(:clinician, :with_address, license_type: "MS")
      create(:clinician_license_type, clinician: clinician_2, license_type: license_type1)
      token_encoded_get("/api/v1/clinicians", params: { search: { credentials: "MD" } },
                        token: @token)

      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["clinicians"]).to be_empty
    end

    it "return no clinicians with special cases 'Recently discharged from a psychiatric hospital'" do
      clinician_1 = create(:clinician, :with_address)
      clinician_2 = create(:clinician, :with_address)
      special_case_1 = create(:special_case)
      special_case_2 = create(:special_case)
      create(:clinician_special_case, special_case: special_case_1, clinician: clinician_1)
      create(:clinician_special_case, special_case: special_case_2,  clinician: clinician_2)
      token_encoded_get("/api/v1/clinicians", params: { search: { special_cases: "Recently discharged from a psychiatric hospital" } },
                        token: @token)
      expect(json_response["meta"]["clinician_count"]).to be < Clinician.count
      expect(json_response["clinicians"]).to be_empty
    end

    it "return no clinicians with special cases 'Recently discharged from a psychiatric hospital'" do
      clinician = create(:clinician)
      clinician_availabilitiy1 = create(:clinician_availability, appointment_start_time: Time.zone.now + 5.hours + 1.day,
                                        appointment_end_time: Time.zone.now + 6.hours)
      create(:clinician_address, clinician: clinician)
      token_encoded_get("/api/v1/clinicians", params: { search: { availability_filter: ["next_three_Days"], utc_offset: 0 } },
                        token: @token)
      expect(json_response["meta"]["clinician_count"]).to eq Clinician.count
    end

    it "with other_providers param returns additional clinicians" do
      clinician = create(:clinician)
      clinician_address = create(:clinician_address, clinician: clinician)

      insurance = create(:insurance)
      facility = create(:facility_accepted_insurance, clinician: clinician, insurance: insurance, clinician_address: clinician_address)
      clinician_address.facility_id = facility.id
      clinician_address.save!
      token_encoded_get("/api/v1/clinician/#{clinician.id}", params: { app_name: 'obie', other_providers: true }, token: @token)
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
      clinician_address_with_same_license_key = create(:clinician_address, office_key: license_key, clinician: clinician_with_same_license_key)
      insurance = create(:insurance)
      facility = create(:facility_accepted_insurance, clinician: clinician, insurance: insurance, clinician_address: clinician_address)
      clinician_address.facility_id = facility.id
      clinician_address.save!

      token_encoded_get("/api/v1/clinician/#{clinician.id}", params: { app_name: 'obie', other_providers: true }, token: @token)

      facilities = clinician.clinician_addresses.all.map(&:facility_id)
      other_clinicians = Clinician.other_providers(clinician, facilities)
      additional_providers = JSON.parse(ActiveModel::Serializer::CollectionSerializer.new(other_clinicians, serializer: OtherClinicianDetailsSerializer).to_json)
      expect(json_response["clinicians"]).to eq additional_providers
    end
  end
end
