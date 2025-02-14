module Obie
  class ClinicianSearchSerializer < ActiveModel::Serializer
    attributes(
      :addresses,
      :ages_accepted,
      :clinician_availabilities,
      :clinician_type,
      :first_name,
      :gender,
      :id,
      :in_office,
      :last_name,
      :license_type,
      :photo,
      :pronouns,
      :provider_id,
      :type_of_cares,
      :video_visit
    )

    has_many :license_types, serializer: LicenseTypeSerializer
    has_many :languages, serializer: LanguageSerializer
    has_many :expertises, serializer: ExpertiseSerializer
    has_many :concerns, serializer: ConcernSerializer
    has_many :populations, serializer: PopulationSerializer
    has_many :interventions, serializer: InterventionSerializer
    has_many :insurances, serializer: InsuranceSerializer

    def id
      object.clinician.id
    end

    def provider_id
      object.clinician.provider_id
    end

    def first_name
      object.clinician.first_name
    end

    def last_name
      object.clinician.last_name
    end

    def clinician_type
      object.clinician.mapped_clinician_type
    end

    def expertises
      object.clinician.expertises
    end

    def concerns
      object.clinician.concerns
    end

    def populations
      object.clinician.populations
    end

    def interventions
      object.clinician.interventions
    end

    def languages
      object.clinician.languages
    end

    delegate :insurances, to: :object

    def gender
      object.clinician.gender
    end

    def pronouns
      object.clinician.pronouns
    end

    def in_office
      object.clinician.in_office
    end

    def video_visit
      object.clinician.video_visit
    end

    def photo
      object.clinician.presigned_photo
    end

    def ages_accepted
      object.clinician.ages_accepted
    end

    # TODO: Refactor
    #
    def clinician_availabilities
      @instance_options[:license_key] = object.office_key if @instance_options[:license_key].blank?

      clinician_availabilities = object.clinician_availabilities.active_data(block_out_hours, object.office_key, object.facility_id, 
@instance_options[:type_of_cares]).with_active_office_keys.order("appointment_start_time")
      if @instance_options[:type_of_cares].present?
        clinician_availabilities = clinician_availabilities.with_type_of_care_availability(@instance_options[:type_of_cares])
      end
      clinician_availabilities = if @instance_options[:patient_status].present? && @instance_options[:patient_status] == "existing"
                                    clinician_availabilities.existing_patient_clinician_availabilities
                                 else
                                    clinician_availabilities.new_patient_clinician_availabilities
                                 end
      if @instance_options[:availability_filter].present?
        if @instance_options[:availability_filter].any? { |s| s.include?("after") || s.include?("before") }
          clinician_availabilities = clinician_availabilities.filter_by_availability_time(@instance_options[:availability_filter], @instance_options[:utc_offset])
        end

        if @instance_options[:availability_filter].any? { |s| s.include?("next") }
          filter_date = ClinicianSearch.availability_days_filter(@instance_options[:availability_filter],
                                                                  @instance_options[:utc_offset])
          clinician_availabilities = clinician_availabilities.availabilities_till_date(filter_date)
        end
      end

      @instance_options[:modality] = Array(@instance_options[:modality])
      if %w[in_office video_visit].any? { |item| @instance_options[:modality].include? item }
        if @instance_options[:modality].include?("in_office") && @instance_options[:modality].include?("video_visit")
          clinician_availabilities = clinician_availabilities.with_modality_availabilities
        elsif @instance_options[:modality].include?("in_office")
          clinician_availabilities = clinician_availabilities.with_in_office_availabilities
          modality = "in_office"
        elsif @instance_options[:modality].include?("video_visit")
          clinician_availabilities = clinician_availabilities.with_virtual_visit_availabilities
          modality = "video_visit"
        end
      end

      clinician_availabilities = if @instance_options[:all_clinician_availabilities]
                                    clinician_availabilities.all
                                 else
                                    clinician_availabilities.first(3)
                                 end

      ActiveModelSerializers::SerializableResource.new(
        clinician_availabilities,
        each_serializer: ClinicianAvailabilitySerializer,
        modality: modality
      )
    end

    def addresses
      [object]
    end

    def type_of_cares
      object.clinician.type_of_cares.pluck(:type_of_care).uniq
    end

    def license_type
      object.clinician.license_type.presence || ""
    end

    def license_types
      object.clinician.license_types
    end

    def block_out_hours
      LicenseKeyRule.block_out_hours_for_license_key(@instance_options[:license_key]) if @instance_options[:license_key].present?
    end
  end
end