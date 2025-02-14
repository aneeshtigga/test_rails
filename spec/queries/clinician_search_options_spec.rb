# spec/qieroes/clinician_search_options_spec.rb

require "rails_helper"


RSpec.describe ClinicianSearchOptions, clinician_search: true do
  before :all do 
    create(:postal_code, zip_code: 90210)
  end

  it "has location params" do
    expected  = [
      :distance,            # in miles; default is 60
      :entire_state,        # Boolean. requires zip_codes to be present
      :zip_codes            # An Array; first is considered home.
    ]

    expect(ClinicianSearchOptions::LOCATION_PARAMS).to eq(expected)
  end


  it "has clarifing params" do
    expected  = [
      :payment_type,                # not a filter; used with insurances || self_pay
      :sort_order,                  # Not a filter; Has "soonest_available" || something else if sort desired
      :utc_offset,                  # Not a filter; used in availability 
      :max_clinicians_per_modality # Not a filter; used to limit results returned 
    ]

    expect(ClinicianSearchOptions::CLARIFING_PARAMS).to eq(expected)
  end


  it "has filter params" do
    expected  = [
      :age,                 # String; value is expected to be Integer
      :app_name,            # String - one and only one
      :availability_filter, # Array of Strings
      :clinician_types,     # Array of Strings
      :concerns,            # Array of Strings
      :credentials,         # Array of Strings
      :expertises,          # Array of Strings
      :facility_ids,        # More than one???? - might be removed?
      :insurances,          # String - one and only one
      :interventions,       # Array of Strings
      :languages,           # Array of Strings
      :license_keys,        # Array of Integers
      :location_names,      # Array of Strings applied to facility_name query
      :modality,            # Array or Strings  Values: in_office || video_visit || both
      :patient_status,      # existing || ???
      :populations,         # Array of Strings || if single just a String
      :pronouns,            # Array of Strings
      :gender,              # Array of Strings
      :search_term,         # Only used for matching clinician name columns.
      :special_cases,       # String - one and only one
      :type_of_cares        # String - one and only one
    ]

    expect(ClinicianSearchOptions::FILTER_PARAMS).to eq(expected)
  end


  it "considers all defined params as valid" do 
    expected  = []

    defined_but_not_valid = ClinicianSearchOptions::VALID_PARAMETERS   -
                            ClinicianSearchOptions::LOCATION_PARAMS    -
                            ClinicianSearchOptions::CLARIFING_PARAMS   -
                            ClinicianSearchOptions::FILTER_PARAMS

    expect(defined_but_not_valid).to eq(expected)
  end


  it ".validate_params(parameters)" do 
    params  = { xyzzy: 'magic' }
    expect { ClinicianSearchOptions.new(params)}.to raise_error(BadParameterError, /xyzzy/)
  end


  it 'returns nil for undefined parameters' do 
    filter = ClinicianSearchOptions.new({})

    expect(filter.xyzzy).to eq(nil)
  end


  it 'denies presents of undefined parameters' do 
    filter = ClinicianSearchOptions.new({})

    expect(filter.xyzzy?).to eq(false)
  end

  ###############################################
  context "age" do 
    it "accesses options with methods, string or symbol keys" do 
      filter = ClinicianSearchOptions.new({"age" => 42 })

      # NOTE: this pattern of access is true for all options

      expect(filter.age).to     eq(42)
      expect(filter['age']).to  eq(42)
      expect(filter[:age]).to   eq(42)
    end

    it "treats age as an integer" do
      filter = ClinicianSearchOptions.new({"age" => 42.3 })

      expect(filter.age).to eq(42)
    end

    it "treats age as an integer without rounding" do
      filter = ClinicianSearchOptions.new({"age" => 42.899 })

      expect(filter.age).to eq(42)
    end
  end


  ###############################################
  context "availability_filter" do
    it 'coerce key :availability_filter to Array' do 
      o = ClinicianSearchOptions.new(availability_filter: "next_three_days", utc_offset: 0)

      expect(o.availability_filter.class.name).to eq("Hashie::Array")
    end


    it "use 0 as default when utc_offset is not present" do 
      params = { availability_filter: "next_three_days" }

      filters = ClinicianSearchOptions.new params

      expect(filters.utc_offset).to eq(0)
    end

    it 'knows the valid availability_filter values' do
      expected = %w[
        after_(1..12)_(am|pm)
        before_(1..12)_(am|pm)
        next_three_days
        next_week
        next_two_weeks
        next_month
      ].sort 

      expect(ClinicianSearchOptions::VALID_AVAILABILITY_FILTER_VALUES.sort).to eq(expected)
    end

    it 'rejects an invalid availability_filter value' do 
      expect  do
        ClinicianSearchOptions.new(zip_codes: 90210, availability_filter: 'xyzzy', utc_offset: 0)
      end.to raise_error(
        BadParameterError,
        /xyzzy/
      )
    end

    it 'rejects multiple after_ values' do 
      expect  do
        ClinicianSearchOptions.new(
          zip_codes: 90210, 
          availability_filter: ['after_12_pm', 'after_5_pm'],
          utc_offset: 0
        )
      end.to raise_error(
        BadParameterError,
        /Can only have one/
      )
    end

    it 'rejects multiple before_ values' do 
      expect  do
        ClinicianSearchOptions.new(
          zip_codes: 90210, 
          availability_filter: ['before_12_pm', 'before_10_am'], 
          utc_offset: 0
        )
      end.to raise_error(
        BadParameterError,
        /Can only have one/
      )
    end

    it 'rejects multiple next_ values' do 
      expect  do
        ClinicianSearchOptions.new(
          zip_codes: 90210, 
          availability_filter: ['next_three_days', 'next_two_weeks'], 
          utc_offset: 0
        )
      end.to raise_error(
        BadParameterError,
        /Can only have one/
      )
    end  
  end


  ###############################################
  context "clinician_types" do 
    it "single String" do
      filter = ClinicianSearchOptions.new(clinician_types: "one TWO thREE")

      expect(filter.clinician_types).to eq("one TWO thREE")
    end
  end
  
  
  ###############################################
  context "concerns" do 
    it "coerces to Array of Strings" do
      filter = ClinicianSearchOptions.new(concerns: "one TWO thREE")

      expect(filter.concerns).to eq(%w[one TWO thREE])
    end
  end


  ###############################################
  context "credentials" do 
    it "coerces to Array of Strings" do
      filter = ClinicianSearchOptions.new(credentials: "one TWO thREE")

      expect(filter.credentials).to eq(%w[one TWO thREE])
    end
  end


  ###############################################
  context "distance" do
    it 'coerce key :distance to Float' do 
      o = ClinicianSearchOptions.new(distance: "15", zip_codes: 90210)

      expect(o.distance.class.name).to  eq("Float")
      expect(o.distance).to             eq(15.0)
    end

    it "rejects distance when zip_codes is not present" do 
      params = { distance: 15 }

      expect  do
        ClinicianSearchOptions.new params
      end.to raise_error(
        BadParameterError,
        "missing parameters: zip_codes"
      )
    end    
  end


  ###############################################
  context "entire_state" do
    it "coerce key :entire_state to boolean - String" do 
      filter = ClinicianSearchOptions.new entire_state: 'true', zip_codes: 90210

      expect(filter.entire_state).to be(true)
    end


    it "coerce key :entire_state to boolean - String as Integer" do 
      filter = ClinicianSearchOptions.new entire_state: "1", zip_codes: 90210

      expect(filter.entire_state).to be(true)
    end


    it "coerce key :entire_state to boolean - Integer" do 
      filter = ClinicianSearchOptions.new entire_state: 1, zip_codes: 90210

      expect(filter.entire_state).to be(true)
    end


    it "coerce key :entire_state to boolean - false String" do 
      filter = ClinicianSearchOptions.new entire_state: 'false'

      expect(filter.entire_state).to be(false)
    end


    it "coerce key :entire_state to boolean - false String as Integer" do 
      filter = ClinicianSearchOptions.new entire_state: "0"

      expect(filter.entire_state).to be(false)
    end


    it "coerce key :entire_state to boolean - false Integer" do 
      filter = ClinicianSearchOptions.new entire_state: 0

      expect(filter.entire_state).to be(false)
    end

    it "rejects entire_state when zip_codes is not present" do 
      params = { distance: 15 }

      expect  do
        ClinicianSearchOptions.new params
      end.to raise_error(
        BadParameterError,
        "missing parameters: zip_codes"
      )
    end
  end

  ###############################################
  context "expertises" do
    it "coerces to Array of Strings" do
      filter = ClinicianSearchOptions.new(expertises: "one TWO thREE")

      expect(filter.expertises).to eq(%w[one TWO thREE])
    end
  end


  ###############################################
  context "facility_ids" do
    it "coerces to Array of Strings" do
      filter = ClinicianSearchOptions.new(facility_ids: "1 2 3")

      expect(filter.facility_ids).to eq([1, 2, 3])
    end
  end


  ###############################################
  context "insurances" do
    it "coerce to Array of Strings" do
      filter = ClinicianSearchOptions.new(insurances: "one TWO thREE")

      expect(filter.insurances).to eq(%w[one TWO thREE])
    end
  end


  ###############################################
  context "interventions" do
    it "coerces to Array of Strings" do
      filter = ClinicianSearchOptions.new(interventions: "one TWO thREE")

      expect(filter.interventions).to eq(%w[one TWO thREE])
    end
  end


  ###############################################
  context "languages" do
    it "coerces to Array of Strings" do
      filter = ClinicianSearchOptions.new(languages: "one TWO thREE")

      expect(filter.languages).to eq(%w[one TWO thREE])
    end
  end


  ############################################
  context "license_keys" do
    before do
      create(:license_key, key: 123456)
    end

    it 'coerce key license_keys to ArrayOfIntegers' do
      o = ClinicianSearchOptions.new(license_keys: "123456")

      expect(o.license_keys.class.name).to eq("Hashie::Array")
      expect(o.license_keys).to            eq([123456])
    end

    it 'validates license_keys' do 
      params = { license_keys: '666' }
      expect {ClinicianSearchOptions.new(params)}.to raise_error(
        BadParameterError,
        "Invalid License Key: 666"
      )
    end
  end


  ############################################
  context "location_names" do
    it 'coerce key location_names to Array' do 
      o = ClinicianSearchOptions.new(location_names: "Downtown Office")

      expect(o.location_names.class.name).to eq("Hashie::Array")
    end
  end


  ############################################
  context "modality parameter" do
    it 'coerce key modality to Array' do
      o = ClinicianSearchOptions.new(modality: "both")

      expect(o.modality.class.name).to eq("Hashie::Array")
    end


    it "has correct modality valid values" do 
      expected  = %w[both in_office video_visit]
      expect(ClinicianSearchOptions::VALID_MODALITY_VALUES).to eq(expected)
    end


    it 'knows valid modality values' do 
      expected = %w[
        both 
        in_office
        video_visit
      ].sort

      expect(ClinicianSearchOptions::VALID_MODALITY_VALUES.sort).to eq(expected)
    end

    it 'rejects invalid modality values' do 
      expect  do
        ClinicianSearchOptions.new(
          zip_codes: 90210, 
          modality: 'xyzzy'
        )
      end.to raise_error(
        BadParameterError,
        /xyzzy/
      )
    end
  end


  ############################################
  context "patient_status" do
    it "single string" do
      filter = ClinicianSearchOptions.new(patient_status: "one TWO thREE")

      expect(filter.patient_status).to eq(%(one TWO thREE))
    end
  end


  ############################################
  context "populations" do
    it "coerces to Array of Strings" do
      filter = ClinicianSearchOptions.new(populations: "one TWO thREE")

      expect(filter.populations).to eq(%w[one TWO thREE])
    end
  end


  ############################################
  context "pronouns" do
    it "coerces to Array of Downcased Strings" do
      filter = ClinicianSearchOptions.new(pronouns: "one TWO thREE")

      expect(filter.pronouns).to eq(%w[one two three])
    end
  end


  ############################################
  context "search_term" do
    it "single string" do
      filter = ClinicianSearchOptions.new(zip_codes: 90210, search_term: "one TWO thREE")

      expect(filter.search_term).to eq("one TWO thREE")
    end

    it "rejects search_term wihtout a zip_code" do 
      expect  do
        ClinicianSearchOptions.new(
          search_term: "one TWO thREE"
        )
      end.to raise_error(
        BadParameterError,
        "missing parameters: zip_codes"
      )

    end
  end


  ############################################
  context "special_cases" do
    it "Returns the array of special cases" do
      filter = ClinicianSearchOptions.new(special_cases: ["one TWO thREE"])

      expect(filter.special_cases).to eq(["one TWO thREE"])
    end
  end


  ############################################
  context "sort_order" do
    it "one and only one string" do
      filter = ClinicianSearchOptions.new(sort_order: "soonest_available")

      expect(filter.sort_order).to eq(%(soonest_available))
    end

    it 'knowns valid sort_order values' do 
      expected = %w[
        most_available
        soonest_available
        nearest_location
      ].sort

      expect(ClinicianSearchOptions::VALID_SORT_ORDER_VALUES.sort).to eq(expected)
    end

    it 'sets a default when not present' do 
      filter = ClinicianSearchOptions.new age: 42
      
      expect(filter.sort_order).to eq(ClinicianSearchOptions::VALID_SORT_ORDER_VALUES.first)
    end

    it 'rejects invalid sort_order values' do 
      expect  do
        ClinicianSearchOptions.new(
          zip_codes:  90210, 
          sort_order: 'xyzzy'
        )
      end.to raise_error(
        BadParameterError,
        /xyzzy/
      )
    end
  end


  ############################################
  context "type_of_cares" do
    it "value is a single string" do
      filter = ClinicianSearchOptions.new(type_of_cares: "one TWO thREE")

      expect(filter.type_of_cares).to eq("one TWO thREE")
    end
  end


  ############################################
  context "zip_codes" do
    it "coerce to Array of unique Strings" do
      filter = ClinicianSearchOptions.new(zip_codes: "90210 90210 90210")

      expect(filter.zip_codes).to eq(["90210"])
    end

    it 'rejects invalid zip_codes' do 
      expect  do
        ClinicianSearchOptions.new(zip_codes: "123456789")
      end.to raise_error(
        BadParameterError,
        'Cannot filter without a valid zip_code: ["123456789"]'
      )
    end

    before do 
      create(:postal_code, zip_code: '09210')
    end

    it "coerce to Array of unique Strings while preserving leading zeros" do
      filter = ClinicianSearchOptions.new(zip_codes: "09210 09210 09210")

      expect(filter.zip_codes).to eq(["09210"])
    end

  end



  ############################################
  context 'validates required parameters' do 
    it "has required parameters" do 
      expected  = [
        { # if key.present?   then values must be present!
          # availability_filter:  [ :utc_offset ], # now using default: 0
          distance:             [:zip_codes],
          entire_state:         [:zip_codes],
          search_term:          [:zip_codes],
        }
      ]

      expect(ClinicianSearchOptions::REQUIRED_PARAMETERS).to eq(expected)
    end
  end
end
