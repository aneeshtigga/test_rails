# == Schema Information
# Schema version: 20230220093953
#
# Table name: postal_codes
#
#  id                  :bigint           not null, primary key
#  city                :string
#  country             :string
#  country_code        :string
#  day_light_saving    :string
#  latitude            :float
#  longitude           :float
#  state               :string
#  state_code          :string
#  time_zone           :string
#  time_zone_abbr      :string
#  utc_offset_sec      :bigint
#  zip_code            :string           indexed
#  zip_codes_by_radius :json
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_postal_codes_on_zip_code  (zip_code)
#
require "rails_helper"

RSpec.describe PostalCode, type: :model do
  include ActiveJob::TestHelper

  describe "constants" do
    it "radius_distance should be present" do
      expect(PostalCode::RADIUS_DISTANCE).to eq(60)
    end

    it "radius_unit should be present" do
      expect(PostalCode::RADIUS_UNIT).to eq("mile")
    end
  end

  describe "validation presence true" do
    it { should validate_presence_of :zip_code }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :latitude }
    it { should validate_presence_of :longitude }
  end

  describe ".get_states" do
    it "returns an array of state abbreviations" do
      %w[AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI
         MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VA WA WV WI WY].each do |state|
        create(:state, name: state)
      end
      expect(PostalCode.get_states.count).to eq 51
    end
  end

  describe ".update_zip_codes" do
    it "enqueues a job for updating a zip code" do
      stub_request(:get, "https://www.zipcodeapi.com/rest/#{Rails.application.credentials.zipcodeApi_key}/state-zips.json/NC")
        .to_return(body: { zip_codes: ["27041"] }.to_json)

      PostalCode.update_zip_codes("NC")

      expect(ZipCodeWorker).to have_been_enqueued.at_least(:once).with("27041")
    end

    it "processes zip codes in batches of 2000" do
      stub_request(:get, "https://www.zipcodeapi.com/rest/#{Rails.application.credentials.zipcodeApi_key}/state-zips.json/NC")
        .to_return(body: { zip_codes: (1..2010).to_a }.to_json)

      PostalCode.update_zip_codes("NC")

      expect(ZipCodeWorker).to have_been_enqueued.exactly(2010).times
      expect(enqueued_jobs.first["wait"].to_i).to eq(0)
      expect(enqueued_jobs[1900]["wait"].to_i).to eq(0)
      # after 2000 zip codes, the next batch should be processed after 1 hour
      wait_time = Time.at(enqueued_jobs[2001][:at]) - Time.now
      expect(wait_time).to be > 3500
    end

    it "should raise an exception when ZipCodeApi reaches the max hourly limit" do
      VCR.use_cassette "update_zip_codes_zipcodeapi_failure" do
        expect do
          PostalCode.update_zip_codes("TX")
        end.to raise_error ZipCodeApiQuotaLimitException

        expect(ZipCodeWorker).to_not have_been_enqueued
      end
    end
  end

  describe ".create_zip_code" do
    before do 
      PostalCode.delete_all
    end

    it "creates the zip code" do      
      VCR.use_cassette "get_zip_code_degrees_success" do
        VCR.use_cassette "zip_codes_within_radius_success" do
          PostalCode.create_zip_code("27041")
        end
      end

      expect(PostalCode.last).to have_attributes(
        city: "Pilot Mountain",
        state: "NC",
        country: "US",
        latitude: 36.425,
        longitude: -80.487,
        day_light_saving: "T",
        time_zone: "America/New_York",
        time_zone_abbr: "EDT",
        utc_offset_sec: -14400
      )
      expect(PostalCode.all.count).to eq(1)
    end

    it "should raise an exception when ZipCodeApi reaches the max hourly limit" do
      VCR.use_cassette "create_zip_code_zipcodeapi_failure" do
        expect do
          PostalCode.create_zip_code("77657")
        end.to raise_error ZipCodeApiQuotaLimitException

        expect(PostalCode.all.count).to eq(0)
      end
    end
  end

  describe ".zip_codes_within_radius_and_state" do
    it "returns a filtered_zipcodes" do
      skip "Test data not setup correctly"

      VCR.use_cassette "zip_codes_within_radius_and_state_success" do

        # At this point there is NO entry for zip code 77657 in the
        # postal_codes table.

        zip_codes = %w[77617 77623 77514 77655 77520 77522 77661 77523 77521 77665 77562 77597 77622 77560 77580 77640
                       77641 77643 77705 77532 77619 77642 77538 77629 77651 77627 77582 77611 77639 77613 77345 77707
                       77535 77336 77630 77713 77701 77575 77704 77710 77720 77725 77726 77702 77533 77631 77706 77670
                       77709 77703 77708 77357 77561 77659 77662 77564 77632 77626 77519 77657 77372 77585 77614 77327
                       77615 77625 77374 77612 77656 77369 77376 77368 77371 77326 77663 75933 77616 77335 77664 77660
                       77332 75928 75956 77624 77399 77351 75979 75990 75942 77350 75966 75934 75951 75938 75936]
        op = { "60_mile" => zip_codes }
        expect(PostalCode.zip_codes_within_radius_and_state("77657")).to eq(op)
      end
    end

    it "should raise an exception when ZipCodeApi reaches the max hourly limit" do
      VCR.use_cassette "zip_codes_within_radius_and_state_zipcodeapi_failure" do
        expect do
          PostalCode.zip_codes_within_radius_and_state("77657")
        end.to raise_error BadParameterError
      end
    end
  end

  describe ".get_zip_code_by_state" do
    it "returns an array of zip codes" do
      VCR.use_cassette "get_zip_code_by_state_success" do
        expect(PostalCode.get_zip_code_by_state("VA")["zip_codes"]).to be_an_instance_of(Array)
      end
    end

    it "should raise an exception when ZipCodeApi reaches the max hourly limit" do
      VCR.use_cassette "get_zip_code_by_state_zipcodeapi_failure" do
        expect do
          PostalCode.get_zip_code_by_state("TX")
        end.to raise_error ZipCodeApiQuotaLimitException
      end
    end
  end

  describe ".get_zip_code_degrees" do
    it "returns an hash of information regarding a given zip code" do
      VCR.use_cassette "get_zip_code_degrees_success" do
        request = PostalCode.get_zip_code_degrees("27041")
        expect(request["zip_code"]).to eq("27041")
        expect(request["state"]).to eq("NC")
      end
    end

    it "should raise an exception when ZipCodeApi reaches the max hourly limit" do
      VCR.use_cassette "get_zip_code_degrees_zipcodeapi_failure" do
        expect do
          PostalCode.get_zip_code_degrees("77657")
        end.to raise_error ZipCodeApiQuotaLimitException
      end
    end
  end

  describe ".zip_codes_within_radius" do
    it "returns an array of zip codes within radius" do
      skip "Test data not setup correctly"

      VCR.use_cassette "zip_codes_within_radius_success" do
        
        # There is no entry for this zip code in the postal_codes table        request = PostalCode.zip_codes_within_radius_and_state("27041", "NC")

        expect(request["60_mile"].count).to eq(199)
      end
    end

    it "returns zipcodes within the state" do
      skip "Test data not setup correctly"

      VCR.use_cassette "zip_codes_within_radius_success" do
        
        # At this point there is no entry for this zip code in the
        # postal_codes table of the test database.  Can't test what is not there.
        
        request = PostalCode.zip_codes_within_radius_and_state("27041", "NC")

        expect(request["60_mile"].count).to eq(199)
      end
    end

    it "should raise an exception when ZipCodeApi reaches the max hourly limit" do
      VCR.use_cassette "zip_codes_within_radius_zipcodeapi_failure" do
        expect do
          PostalCode.zip_codes_within_radius_and_state("77657")
        end.to raise_error BadParameterError
      end
    end
  end


  ################################################################
  context "Geokit::Mappable" do 
    it 'has correct lat/lng column names at the class level' do 
      expect(PostalCode.lat_column_name).to eq('latitude')
      expect(PostalCode.lng_column_name).to eq('longitude')
    end
  end
end