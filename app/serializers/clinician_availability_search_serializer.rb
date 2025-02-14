class ClinicianAvailabilitySearchSerializer < ActiveModel::Serializer
  attributes :clinician_availability_key, :license_key, :available_date, :profile_id, :provider_id, :npi, :facility_id, :reason,
             :appointment_start_time, :appointment_end_time, :type_of_care, :virtual_or_video_visit, :in_person_visit, :column_id, :duration

  def clinician_availability_key
    object.clinician_availability_key.to_s
  end

  def available_date
    object.available_date.to_date
  end

  def appointment_start_time
    object.appointment_start_time.strftime("%I:%M %p")
  end

  def appointment_end_time
    object.appointment_end_time.strftime("%I:%M %p")
  end

  def duration
    object.get_duration_time
  end
end
