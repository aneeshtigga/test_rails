class AmdAppointmentSchedulerService
  def initialize(patient, clinician_availability, episode_id, modality, time_zone = "America/New_York")
    @clinician_availability = clinician_availability
    @patient = patient
    @episode_id = episode_id
    @time_zone = time_zone
    @modality = modality
  end

  def schedule_appointment
    response = client.appointments.add_appointment(payload)
    if response["id"].present?
      client.auto_assign_forms.auto_assign(response)
      response
    else
      false
    end
  end

  private

  attr_reader :patient, :clinician_availability, :episode_id, :time_zone

  def payload
    {
      patientid: patient.amd_patient_id,
      columnid: clinician_availability.column_id,
      color: @modality == :in_office ? clinician_availability.in_person_color&.strip : clinician_availability.tele_color&.strip,
      startdatetime: clinician_availability.appointment_start_time.in_time_zone(time_zone).strftime("%Y-%m-%dT%H:%M:%S.%L"),
      duration: clinician_availability.duration,
      profileid: clinician_availability.profile_id,
      type: type_of_cares_amd_appt_type_uids,
      episodeid: episode_id,
      comments: patient.about,
      facilityid: clinician_availability.facility_id
    }
  end

  def get_amd_tele_appt_type_id_for_toro
    clinician.type_of_cares.with_non_follow_up_cares
             .where({type_of_care: clinician_availability.type_of_care, facility_id: clinician_availability.facility_id})
             .where("amd_appointment_type like ?", 'TELE%').first.amd_appt_type_uid
  end

  def type_of_cares_amd_appt_type_uids
    type_of_cares.map do |toc|
      amd_appt_type_id = toc.amd_appt_type_uid
      amd_appointment_type_value = toc.amd_appointment_type

      # this is an interim fix, to update TORO tele visit with correct amd_appt_type value & id, that AMD accepts
      if clinician_availability.reason =~ /TORO$/ && @modality == :video_visit
        amd_appt_type_id = get_amd_tele_appt_type_id_for_toro
        amd_appointment_type_value = 'TELE ' + toc.amd_appointment_type
      end

      { "id" => amd_appt_type_id,
        "name" => amd_appointment_type_value }
    end
  end

  def type_of_cares
    hash = {}
    hash[:type_of_care] = clinician_availability.type_of_care
    hash[:facility_id] = clinician_availability.facility_id

    # For the below combination of clinician_availablity.reason, we set boolean flags for, :in_person_visit & :virtual_or_video_visit
    #
    # == Ends with TORO (Virtual/Video Visit OR In-Office Visit)
    #    1. IA TORO
    #    2. IA OR F/U TORO
    #    3. IA or F/U TORO
    #
    # == Ends with OFFC (In-Office Visit)
    #    1. IA OFFC
    #    2. IA or F/U OFFC
    #
    # NOTE: for this particular condition, we are NOT setting virtual_or_video_visit values.
    #       Per the logic we need to set virtual_or_video_visit=false. But, we do not have any records in type_of_cares for boolean FALSE, as our data teams is setting TRUE by default.
    #       In Sub-Sequent sprints, when the data team fixes this issue, we need to uncomment line 76 .
    #
    # == Ends with TELE (Virtual OR Video Visit)
    #    1. IA TELE
    #    2. IA or F/U TELE

    case clinician_availability.reason
    when /TORO$/
      hash[:in_person_visit] = 1
      hash[:virtual_or_video_visit] = 1
    when /OFFC$/
      hash[:in_person_visit] = 1
      # hash[:virtual_or_video_visit] = 0 # uncomment, after data-team fixes the default TRUE issue
    when /TELE$/
      hash[:in_person_visit] = 0
      hash[:virtual_or_video_visit] = 1
    end

    clinician.type_of_cares.with_non_follow_up_cares.where(hash)
  end

  def clinician
    Clinician.find_by(provider_id: clinician_availability.provider_id, license_key: clinician_availability.license_key)
  end

  def client
    @client ||= Amd::AmdClient.new(office_code: clinician_availability.license_key)
  end
end
