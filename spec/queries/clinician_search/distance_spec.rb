# spec/queries/clinician_search/distance_spec.rb

require "rails_helper"

RSpec.describe "ClinicianSearch - distance", clinician_search: true do

  before :all do 
    # Using utc_offset of zero and a fixed UTC time to make the
    # SQL queries consistent and easily understood.
    #
    @testing_time = Time.utc(2023, 6, 3, 14, 45, 0o0, 0, 0) # Saturday
  
    Timecop.freeze(@testing_time)
  end

  
  context "Testing distance calculations etc." do 
    before :all do
      ClinicianAddress.delete_all

      [
        {
          id:             111111,
          city:           "Houston",
          state:          "TX",
          postal_code:    "77084",
          facility_id:    78,
          facility_name:  "Katy",
          latitude:       29.793,
          longitude:      -95.704,
        },
        {
          id:             222222,
          city:           "Houston",
          state:          "TX",
          postal_code:    "77024",
          facility_id:    1988,
          facility_name:  "Memorial Dr",
          latitude:       29.765,
          longitude:      -95.551,
        },
        {
          id:             333333,
          city:           "Houston",
          state:          "TX",
          postal_code:    "77024",
          facility_id:    931,
          facility_name:  "Midtown",
          latitude:       29.787,
          longitude:      -95.497,
        },
        {
          id:             444444,
          city:           "Houston",
          state:          "TX",
          postal_code:    "77098",
          facility_id:    83,
          facility_name:  "River Oaks",
          latitude:       29.737,
          longitude:      -95.428,
        },
        {
          id:             555555,
          city:           "Houston",
          state:          "TX",
          postal_code:    "77070",
          facility_id:    1837,
          facility_name:  "Tomball",
          latitude:       29.784,
          longitude:      -95.361,
        },
        {
          id:             666666,
          city:           "Houston",
          state:          "TX",
          postal_code:    "77070",
          facility_id:    1837,
          facility_name:  "Tomball",
          latitude:       29.979,
          longitude:      -95.564,
        },
        {
                  id: 777777,
                city: "The Woodlands",
               state: "TX",
         postal_code: "77380",
         facility_id: 1106,
       facility_name: "The Woodlands",
            latitude: 30.175,
           longitude: -95.469,
        },
        {
                  id: 888888,
                city: "Dallas",
               state: "TX",
         postal_code: "75243",
         facility_id: 2051,
       facility_name: "New Heights Counseling Dallas Office",
            latitude: 32.901,
           longitude: -96.768,
        },
        {
                  id: 999999,
                city: "Friendswood",
               state: "TX",
         postal_code: "77546",
         facility_id: 59,
       facility_name: "Friendswood",
            latitude: 29.53,
           longitude: -95.202,
        }
      ].each do |values|
        FactoryBot.create(:clinician_address, values)
      end

      FactoryBot.create(  
        :postal_code,
        zip_code:  "77051",
        city:      "Houston",
        state:     "TX",
        country:   "US",
        latitude:  29.656,
        longitude: -95.378
      )
    end


    it "knows how to calculate distances" do 
      home = PostalCode.find_by zip_code: 77051

      {
        111111 => 21.8,  
        222222 => 12.8,
        333333 => 11.5,
        444444 => 6.4,
        555555 => 8.9,
        666666 => 25.0,
        777777 => 36.3,
        888888 => 239.0,
        999999 => 13.7
      }.each do |ca_id, expected_distance|
        ca        = ClinicianAddress.find ca_id
        in_miles  = home.distance_to ca 

        expect(in_miles.round(1)).to eq(expected_distance)
      end
    end


    it "when filtering on distance it raises error without zip_code" do
      params    = { distance: '5' }
      expect {ClinicianSearch.clinicians_by_location(params)}.to( 
        raise_error(BadParameterError, "missing parameters: zip_codes")
      )
    end


    it "filters on distance - bad value" do
      expected  = "xyzzy"
      params    = { distance: 'xyzzy', zip_codes: "77051" }
      
      expect {ClinicianSearch.clinicians_by_location(params)}.to(   
        raise_error(BadParameterError, /Invalid distance/)
      )
    end


    it "filters on distance - bad value - negative" do
      expected  = "xyzzy"
      params    = { distance: '-15', zip_codes: "77051" }

      expect {ClinicianSearch.clinicians_by_location(params)}.to(
        raise_error(BadParameterError, /Invalid distance/)
      )
    end


    it "filters on distance - bad value - zero" do
      expected  = "xyzzy"
      params    = { distance: '0', zip_codes: "77051" }

      expect { ClinicianSearch.clinicians_by_location(params) }.to(
        raise_error(BadParameterError, /Invalid distance/)
      )
    end


    it "filters on distance - bad value - empty string" do
      expected  = "xyzzy"
      params    = { distance: '', zip_codes: "77051" }

      expect {ClinicianSearch.clinicians_by_location(params)}.to(
        raise_error(BadParameterError, /Invalid distance/)
      )
    end


    it "filters on distance - bad value - blank string" do
      expected  = "xyzzy"
      params    = { distance: '   ', zip_codes: "77051" }

      expect { ClinicianSearch.clinicians_by_location(params) }.to(
        raise_error(BadParameterError, /Invalid distance/)
      )
    end


    # NOTE: if it works for 5 miles it will work for X miles.
    #
    it "filters on distance - 5 miles" do
      params    = { distance: '5', zip_codes: "77051" }
      expected  = []

      result    = ClinicianSearch.clinicians_by_location(params)

      expect(result.to_a).to eq(expected)
    end
  end
end
