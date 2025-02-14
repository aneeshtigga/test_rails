class BookAppointmentService
  def initialize(clinician_availability, patient, booked_by = "patient")
    @clinician_availability = clinician_availability
    @patient = patient
    @booked_by = (booked_by.presence || "patient")
  end

  def create_appointment!
    # loop through all the booking_rules and make sure they all pass
    booking_rules.each do |rule|
      return false unless rule.passes_for?(appointment)
    end

    amd_appointment_id = amd_scheduler.schedule_appointment

    amd_appointment_id = amd_appointment_id.is_a?(Hash) ? amd_appointment_id["id"] : amd_appointment_id
    if amd_appointment_id.present?
      Appointment.transaction do
        appointment.save!
        patient_appointment.appointment = appointment
        patient_appointment.amd_appointment_id = amd_appointment_id
        patient_appointment.booked_by = booked_by

        patient_appointment.save!
        # When an appointment is succesfully created, we create a record in ClinicianAvailabilityStatus
        # with the clinician_availability_key, therefore, it should not be within the default scope.
        ClinicianAvailabilityStatus.create(
          clinician_availability_key: @clinician_availability.clinician_availability_key,
          status: :scheduled, 
          available_date: @clinician_availability.available_date
        )
      end
    end

    if patient_appointment.persisted? && patient_appointment.booked_by == "patient"

      PatientAppointmentConfirmationMailerWorker.perform_async(patient_appointment.id)

      patient_appointment
    elsif patient_appointment.persisted? && patient_appointment.booked_by == "admin"

      PatientAppointmentHoldMailerWorker.perform_async(patient_appointment.id)

      patient_appointment
    end
  end

  def post_policy_holder
    if patient_insurance.present? && patient_insurance.relation_to_policy_holder != "self"
      amd_responsible_party_id = nil
      amd_responsible_party = patient.client.responsible_parties.lookup_responsible_party(amd_responsible_party_lookup_params)
      amd_responsible_party_id = amd_responsible_party&.id
      if amd_responsible_party_id.nil?
        amd_responsible_party = patient.client.responsible_parties.add_responsible_party(amd_policy_holder_params)
        amd_responsible_party_id = amd_responsible_party["@id"]&.gsub(/\D/, "")
      else
        amd_responsible_party_id = amd_responsible_party_id&.gsub(/\D/, "")
      end
      raise "Responsible party amd api fail" if amd_responsible_party_id.blank?

      patient_insurance.policy_holder.update!(amd_id: amd_responsible_party_id)
    end
  end
  
  private

  attr_reader :clinician_availability, :patient, :booked_by

  def patient_insurance
    @patient.insurance_coverages.last
  end

  def appointment
    @appointment ||= Appointment.new(
      clinician: clinician,
      clinician_address: clinician_address,
      patient: patient,
      clinician_availability_key: clinician_availability.clinician_availability_key,
      start_time: clinician_availability.appointment_start_time,
      end_time: clinician_availability.appointment_end_time,
      type_of_care: clinician_availability.type_of_care,
      reason: clinician_availability.reason,
      modality: modality
    )
  end

  def patient_appointment
    @patient_appointment ||= PatientAppointment.new(
      patient: patient,
      clinician: clinician,
      clinician_address: clinician_address,
      status: :booked,
      cbo: clinician.cbo,
      license_key: clinician.license_key
    )
  end

  def clinician_address
    clinician.clinician_addresses.find_by(facility_id: clinician_availability.facility_id)
  end

  def modality
    selected_modality = @patient.account_holder.selected_slot_info.dig("reservation", "modality")
    case selected_modality
    when "IN-OFFICE"
      :in_office
    when "VIDEO"
      :video_visit
    else
      raise "No modality selected"
    end
  end

  def clinician
    Clinician.active.find_by(provider_id: clinician_availability.provider_id, license_key: clinician_availability.license_key)
  end

  def amd_scheduler
    postal_code = PostalCode.find_by(zip_code: clinician_address.postal_code)
    AmdAppointmentSchedulerService.new(patient, clinician_availability, episode_id, modality, postal_code.time_zone)
  end

  def episode_id
    @episode_id ||= client.episodes.episode_id(patient.amd_patient_id)
  end

  def client
    @client ||= Amd::AmdClient.new(office_code: clinician_availability.license_key)
  end

  def policy_holder_service
    @policy_holder_service ||= Amd::Data::PatientInsuranceCoverage.new(patient)
  end

  def amd_policy_holder_params
    policy_holder_service.payload
  end

  def amd_responsible_party_lookup_params
    policy_holder_service.lookup_payload
  end

  def booking_rules
    [AdvancedNoticeRule, LicenseKeyBlockoutRule]
  end
end
