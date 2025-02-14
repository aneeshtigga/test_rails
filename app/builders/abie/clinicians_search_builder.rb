module Abie
  class CliniciansSearchBuilder
    def initialize(params)
      params[:app_name] = 'abie'
      @search_parameters = params
    end

    # Primary entry point from the controller class
    # params is the permitted parameters as defined by the controller
    #
    # returns an Array of Hashes
    #
    def self.build(params)
      builder = new(params)
      builder.find_clinicians_by_search_params
      builder.process
      builder.filter
    end

    # FIXME: this method should be refactored. Serializing, then deserializing straight after is not cool
    def process
      serialized_clinician_list = build_serialized_clinician_list(@search_parameters)

      @results = JSON.parse(serialized_clinician_list.to_json)
    end

    def filter
      # reject a clinician, if clinician_availabilities is empty
      @results.reject! { |each_result| each_result['clinician_availabilities']&.empty? }

      # if we have a max_clinicians_per_modality, then we need to filter the results
      # to include a maximum of that many clinician_availabilities for each modality
      if @search_parameters[:max_clinicians_per_modality]

        @results.each do |clinician|
          virtual_or_video_visits = 0
          in_person_visits = 0
          max_clinicians_per_modality = @search_parameters[:max_clinicians_per_modality]

          # sort the clinician_availabilities by available_date and appointment_start_time
          clinician["clinician_availabilities"].sort_by! do |availability|
            DateTime.parse("#{availability['available_date']} #{availability['appointment_start_time']}")
          end

          # delete all but the first 3 of each modality
          clinician["clinician_availabilities"].delete_if do |availability|
            do_delete = true
            if availability["virtual_or_video_visit"] == 1 && virtual_or_video_visits < max_clinicians_per_modality
              do_delete = false
              virtual_or_video_visits += 1
            end
            if availability["in_person_visit"] == 1 && in_person_visits < max_clinicians_per_modality
              do_delete = false
              in_person_visits += 1
            end
            do_delete
          end
        end
      end

      # The front-end is expecting the "distance_in_miles" at a different
      # place within the Hash/JSON object so move it from it attribute
      # position within the ClinicianAddress hash to the place where FE
      # expects it to be.
      #
      @results.each do |clinician|
        clinician["distance_in_miles"] = clinician["addresses"]&.first&.[]("distance_in_miles")
        clinician["addresses"].each do |address|
          address.delete('distance_in_miles')
        end
      end

      @results
    end

    def find_clinicians_by_search_params
      @results = ClinicianSearch.clinicians_by_location(@search_parameters)
    end

    def get_postal_code(zip_code)
      PostalCodeBuilder.build(zip_code)
    end
  end
end
