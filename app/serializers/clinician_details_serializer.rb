class ClinicianDetailsSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :in_office, :manages_medication, :ages_accepted, :provider_id
  attributes :credentials, :about, :virtual_visit, :facility_location, :type, :languages_spoken, :photo
  attributes :pronouns, :telehealth_url, :license_key, :gender, :type_of_cares, :supervisor_data, :insurances
  has_many :expertises
  has_many :interventions, serializer: InterventionSerializer
  has_many :populations, serializer: PopulationSerializer
  has_many :insurances, serializer: InsuranceSerializer
  has_many :educations, serializer: EducationSerializer

  def insurances
    object.insurances_for_app(@instance_options[:app_name])
  end
  
  def credentials
    object.license_type
  end

  def about
    object.about_the_provider
  end

  def virtual_visit
    object.video_visit
  end

  def facility_location
    ActiveModelSerializers::SerializableResource.new(object.clinician_addresses, each_serializer: Obie::V1::ClinicianAddressSerializer,
                                                     type_of_cares: @instance_options[:type_of_cares],
                                                     patient_status: @instance_options[:patient_status],
                                                     postal_code: @instance_options[:postal_code]).as_json
  end

  def languages_spoken
    ActiveModelSerializers::SerializableResource.new(object.languages).as_json
  end

  def type
    object.mapped_clinician_type
  end

  def photo
    object.presigned_photo
  end

  def type_of_cares
    object.type_of_cares.pluck(:type_of_care).uniq.select { |type_of_care| type_of_care.exclude?("Follow Up") }
  end

  def supervisor_data
    supervisors = object.facility_accepted_insurances.pluck(:supervisors_name, :license_number).uniq
    supervisory_keys = %w[full_name license_number]
    # We transform nils to blank spaces for FE
    supervisor_data = supervisors.map do |records|
      records = records.map { |r| r.presence || "" }
      supervisory_keys.zip(records).to_h
    end
    {
      supervised_clinician: object.supervised_clinician.present?,
      supervisors: supervisor_data
    }
  end
end
