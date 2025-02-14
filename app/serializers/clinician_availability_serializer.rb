class ClinicianAvailabilitySerializer < ActiveModel::Serializer
  attributes :clinician_availability_key, :license_key, :available_date, :profile_id, :provider_id, :npi, :facility_id, :reason, :appointment_start_time, :appointment_end_time, :type_of_care, :virtual_or_video_visit, :in_person_visit, :rank_most_available, :rank_soonest_available, :column_id

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

  def virtual_or_video_visit
    if @instance_options[:modality].present? && @instance_options[:modality]=="in_office"
      0
    else
      object.virtual_or_video_visit
    end
  end

  def in_person_visit
    if @instance_options[:modality].present? && @instance_options[:modality]=="video_visit"
      0
    else
      object.in_person_visit
    end
  end
end
