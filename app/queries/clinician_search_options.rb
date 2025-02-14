# app/queries/clinician_search_options.rb

#   ClinicianSearchOptions extracts all of the management and validation
#   processes around the parameters used to do the filtering of a
#   clinician search process.
#
#   TODO: Consider adding strict_key_access
#
#   Typical Usage:
#     # params can either be a Hash or an ActiveController::Parameters object
#     # Its keys can be symbols or strings.
#     params = { age: 42, zip_codes: 77051, 
#               type_of_cares: "Adult Therapy", distance: 7, 
#               availability_filter: ['next_three_days'], 
#               utc_offset: 360}
#
#     # BadParameterError is raised if params contains an invalid key
#
#     filters = ClinicianSearchOptions.new(params)
#
#     # The presents? of an option is accessed like this:
#     filters.zip_codes?
#
#     # when filters.any_param? is false
#     # then filters.any_param will return nil 
#
#     # The value of an option can be accessed in several ways
#     filters.zip_codes
#     filters[:zip_codes]
#     filters['zip_codes']
#

require 'hashie/extensions/coercion'

class ClinicianSearchOptions < Hashie::Mash
  include Hashie::Extensions::Coercion


  class ArrayOfStrings
    def self.coerce(value)
      case value
      when String
        value&.split&.uniq
      when Array
        value&.map {|e| e&.to_s&.strip}&.uniq
      else
        [value&.to_s]
      end
    end
  end

  class ArrayOfDowncasedStrings
    def self.coerce(value)
      ArrayOfStrings.coerce(value).map(&:downcase)&.uniq
    end
  end

  class ArrayOfIntegers
    def self.coerce(value)
      ArrayOfStrings.coerce(value).map(&:to_i)
    end
  end

  class Boolean
    def self.coerce(value)
      case value
      when String
        (value =~ /(true|t|yes|y|1)/i).present?
      when Numeric
        !value.to_i.zero?
      else
        value == true
      end
    end
  end

  coerce_key :age,                  Integer
  coerce_key :availability_filter,  ArrayOfDowncasedStrings
  coerce_key :clinician_types,      String # ArrayOfStrings
  coerce_key :concerns,             ArrayOfStrings
  coerce_key :credentials,          ArrayOfStrings
  coerce_key :distance,             Float
  coerce_key :entire_state,         Boolean
  coerce_key :expertises,           ArrayOfStrings
  coerce_key :facility_ids,         ArrayOfIntegers
  coerce_key :insurances,           ArrayOfStrings
  coerce_key :interventions,        ArrayOfStrings
  coerce_key :languages,            ArrayOfStrings
  coerce_key :license_keys,         ArrayOfIntegers
  coerce_key :location_names,       ArrayOfStrings
  coerce_key :modality,             ArrayOfDowncasedStrings  
  coerce_key :patient_status,       String
  coerce_key :populations,          ArrayOfStrings
  coerce_key :pronouns,             ArrayOfDowncasedStrings
  coerce_key :gender,               ArrayOfDowncasedStrings
  coerce_key :search_term,          String
  coerce_key :special_cases,        ArrayOfStrings
  coerce_key :type_of_cares,        String
  coerce_key :utc_offset,           Integer
  coerce_key :zip_codes,            ArrayOfStrings


  # These are the parameters which deal with a clinicians
  # geographic location.
  #
  LOCATION_PARAMS   = [
    :distance,            # in miles; default is 60
    :entire_state,        # Boolean. requires zip_codes to be present
    :zip_codes            # Array of Strings; first one is considered "home"
  ].freeze

  # These parameters are not specifically filter values.  They
  # amplify/endorse/clarify other filter parameters.
  #
  CLARIFING_PARAMS  = [
    :payment_type,                # not a filter; used with insurances || self_pay
    :sort_order,                  # Not a filter; Has "soonest_available" || something else if sort desired
    :utc_offset,                  # Not a filter; used in availability; units of measure is minutes
    :max_clinicians_per_modality  # Not a filter; used to limit the number of clinicians returned per modality
  ].freeze

  # These parameters invoke a specific filtering process.
  #
  FILTER_PARAMS     = [
    :age,                 # String; value is expected to be Integer
    :app_name,            # String; either "obie" or "abie"
    :availability_filter, # Array of Strings; 1+ entries consisting ot 2 types
    #   1st type is (before|after)_(hour:\d)_(AM|PM)
    #   2nd type is one of these strings:
    #     next_three_days
    #     next_week
    #     next_two_weeks
    #     next_month
    #
    # Example Value:
    #   #w[before_12_pm after_3_pm next_week]
    #
    # NOTE: The front-end is using discrete values for the hour component
    #       of the before and after values; however, the backend will
    #       extract the hour component and use it without validation that it is one
    #       of the discreat values used by the FE.
    #       Also the FE will only send 1 before and/or 1 after
    #       value.  If the user selects more than one before/afater
    #       then the FE choosed that latest value for before and the
    #       soonest value for after.
    #
    :clinician_types,     # Array of Strings
    :concerns,            # Array of Strings
    :credentials,         # Array of Strings
    :expertises,          # Array of Strings
    :facility_ids,        # ??? More than one???? - might be removed?
    :insurances,          # String - one and only one
    :interventions,       # Array of Strings
    :languages,           # Array of Strings
    :license_keys,        # Array of Integers
    :location_names,      # Array of Strings; applied to facility_name query
    :modality,            # Array or Strings  Values: in_office || video_visit || both
    :patient_status,      # existing || ???
    :populations,         # ??? Array of Strings || if single just a String
    :pronouns,            # Array of Strings
    :gender,              # Array of Strings
    :search_term,         # Only used for matching clinician name columns.
    :special_cases,       # String - one and only one
    :type_of_cares       # String - one and only one
  ].freeze

  VALID_PARAMETERS  = LOCATION_PARAMS + CLARIFING_PARAMS + FILTER_PARAMS

  # Array of Symbols or Hashes with Symobls of those parameters
  # that are required.  An entry which is a Symbol is alwasy required.
  # An entry that is a Hash means that if the key is present then
  # all of the values are required.
  #
  REQUIRED_PARAMETERS = [
    { # if key.present?   then values must be present!
      # availability_filter:  [ :utc_offset ],
      distance:             [:zip_codes],
      entire_state:         [:zip_codes],
      search_term:          [:zip_codes],
    }
  ].freeze


  VALID_MODALITY_VALUES = %w[both in_office video_visit].freeze

  VALID_AVAILABILITY_FILTER_VALUES = %w[
    after_(1..12)_(am|pm)
    before_(1..12)_(am|pm)
    next_three_days
    next_week
    next_two_weeks
    next_month
  ].freeze

  # NOTE: default value is the first entry
  VALID_SORT_ORDER_VALUES = %w[
    most_available
    soonest_available
    nearest_location
  ].freeze

  # hash_object is either Hash or
  # ActionController::Parameters
  #
  def self.new(hash_object)
    symbolized_hash = hash_object.to_h.symbolize_keys

    validate_parameters(symbolized_hash.keys)

    me = super(symbolized_hash)

    validate_required(me)
    validate_option_values(me)
    set_default_options(me)

    me
  end

  def self.validate_required(this)
    errors = []

    REQUIRED_PARAMETERS.each do |need|
      if need.is_a? Symbol
        errors << need unless this.send("#{need}?")
      elsif need.is_a? Hash 
        need.each_pair do |key, values|
          next unless this.send("#{key}?")

          values.each do |value|
            errors << value unless this.send("#{value}?")
          end
        end
      end
    end

    unless errors.empty?
      raise(
        BadParameterError, 
        "missing parameters: #{errors.join(', ')}"
      ) 
    end
  end

  def self.validate_parameters(param_keys)
    bad_keys = param_keys - VALID_PARAMETERS
    
    unless bad_keys.empty?
      raise(
        BadParameterError, 
        "bad parameters: #{bad_keys.join(', ')}"
      ) 
    end
  end


  #########################################################
  ## Validate the value of those options which have known
  ## values.

  def self.validate_option_values(this)    
    validate_availability_filter(this)  if this.availability_filter?    
    validate_distance(this)             if this.distance?
    validate_license_keys(this)         if this.license_keys?
    validate_modality(this)             if this.modality?
    validate_sort_order(this)           if this.sort_order?
    validate_zip_codes(this)            if this.zip_codes?
    validate_search_term(this)          if this.search_term?
  end

  def self.validate_availability_filter(this)
    bad_options = (this.availability_filter - VALID_AVAILABILITY_FILTER_VALUES)
                  .reject do |e| 
                      e.start_with?('after_', 'before_')  &&
                        e.end_with?('_am', '_pm')         &&
                        e.split('_').size == 3
                  end

    has_hour = this.availability_filter.select do |v| 
      v.start_with?('after_', 'before_')      
    end

    has_hour -= bad_options

    # At this point we know that the has_hour options are
    # correctly formatted.

    has_hour.each do |option|
      hour  = option.split("_")[1].to_i

      bad_options << option unless (1..12).cover?(hour)
    end

    unless bad_options.empty?
      raise(
        BadParameterError, 
        "Invalid options: #{bad_options.join(', ')}"
      ) 
    end

    after_cnt   = this.availability_filter.count {|e| e.start_with? 'after_'}
    before_cnt  = this.availability_filter.count {|e| e.start_with? 'before_'}
    next_cnt    = this.availability_filter.count {|e| e.start_with? 'next_'}
    
    raise BadParameterError, "Can only have one each of the after_ before_ and next_ availability_filter values" if after_cnt > 1 || before_cnt > 1 || next_cnt > 1
  end

  def self.validate_distance(this)
    raise BadParameterError, "Invalid distance: #{this.distance}" if this.distance <= 0.0

    raise(BadParameterError, "Cannot filter without a valid zip_code") unless this.zip_codes?
  end

  def self.validate_license_keys(this)
    good_keys = LicenseKey.where(key: this.license_keys).pluck(:key)
    bad_keys  = this.license_keys - good_keys

    unless bad_keys.empty?
      raise(
        BadParameterError, 
        "Invalid License Key: #{bad_keys.join(', ')}"
      )
    end
  end

  # Front-end is inconsistent, and can send either in_office or IN-OFFICE, et cetera
  def self.validate_modality(this)
    this.modality.map! { |entry| entry.match?(/office/i) ? 'in_office'   : entry }
    this.modality.map! { |entry| entry.match?(/video/i)  ? 'video_visit' : entry }

    bad_options = this.modality - VALID_MODALITY_VALUES

    unless bad_options.empty?
      raise(
        BadParameterError, 
        "Invalid modality options: #{bad_options.join(', ')}"
      ) 
    end

    if  this.modality.include?("in_office")   && 
        this.modality.include?("video_visit")
      this.modality = ["both"]
    end
  end

  # side-effect ... front-end does not send entire_state parameter so set it
  def self.validate_search_term(this)
    this.entire_state = true
  end

  def self.validate_sort_order(this)
    unless VALID_SORT_ORDER_VALUES.include?(this.sort_order)
      raise(
        BadParameterError, 
        "Invalid sort_order options: #{this.sort_order}"
      ) 
    end
  end

  def self.validate_zip_codes(this)
    postal_code = PostalCode.find_by(zip_code: this.zip_codes&.first)
    
    if postal_code.blank?
      raise(
        BadParameterError,
        "Cannot filter without a valid zip_code: #{this.zip_codes}"
      )
    end
  end



  #########################################################
  ## Set the default value for those options which have
  ## default values.

  def self.set_default_options(this)
    set_default_sort_order(this) unless this.sort_order?  
    set_default_utc_offset(this) unless this.utc_offset?  
  end

  def self.set_default_sort_order(this)
    this[:sort_order] = VALID_SORT_ORDER_VALUES.first   
  end

  # NOTE: setting a default for utc_offset rather than making it
  #       required parameter when availability_filter is present
  #       is done because there are lots of test data in the specs
  #       that do not pass a utc_offset parameter.
  def self.set_default_utc_offset(this)
    this[:utc_offset] = 0   
  end
end
