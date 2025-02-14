class PatientAppointmentSerializer < ActiveModel::Serializer
  attributes :id, :clinician, :clinician_address, :appointment_start_time, :appointment_end_time, :duration,
             :support_info, :marketing_referral_phone
  attributes :modality, :type_of_care, :booked_by, :appointment_occurred_in_past

  def modality
    object.appointment.modality
  end

  def appointment_start_time
    object.start_time.utc
  end

  def appointment_end_time
    object.end_time.utc
  end

  def clinician
    {
      id: object.clinician.id,
      first_name: object.clinician.first_name,
      last_name: object.clinician.last_name,
      license_type: object.clinician.license_type,
      telehealth_url: object.clinician.telehealth_url,
      profile_photo: object.clinician.presigned_photo
    }
  end

  def clinician_address
    {
      id: object.clinician_address.id,
      address_line1: object.clinician_address.address_line1,
      address_line2: object.clinician_address.address_line2,
      city: object.clinician_address.city,
      state: object.clinician_address.state,
      postal_code: object.clinician_address.postal_code,
      facility_name: object.clinician_address.facility_name,
      license_key: object.clinician_address.office_key,
    }
  end

  def support_info
    {
      support_number: object.support_info.intake_call_in_number,
      location: object.support_info.location,
      support_hours: object.support_info.support_hours,
      established_patients_call_in_number: object.support_info.established_patients_call_in_number,
      follow_up_url: object.support_info.follow_up_url
    }
  end

  def appointment_occurred_in_past
    object.appointment_occurred_in_past?
  end
end
