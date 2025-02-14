class PatientAppointmentMailer < ApplicationMailer
  has_history extra: -> { { patient_id: params[:patient_appointment].patient.id} }

  def appointment_confirmation
    attach_images
    @patient_appointment = params[:patient_appointment]
    @patient = @patient_appointment.patient
    @clinician = @patient_appointment.clinician
    @office_key = @patient_appointment.clinician_address.office_key

    postal_code = @patient_appointment.clinician_address.postal_code
    postal_code_data = PostalCode.find_by(zip_code: postal_code)
    clinician_state = @patient_appointment.clinician_address.full_state
    @time_zone = postal_code_data.present? ? postal_code_data.time_zone : "America/New_York"
    @time_zone_abbr = postal_code_data.present? ? postal_code_data.time_zone_abbr : "EST"
    @appointment_start_time = @patient_appointment.start_time.in_time_zone("#{@time_zone}")
    @support_number = intake_phone_number(@patient_appointment.clinician_address.state)
    @lfs_patient_portal_link = "https://patientportal.advancedmd.com/#{@office_key}/account/logon"
    @cancellation_link = "#{Rails.application.credentials.host_url}/find-care/intake/cancellation?id=#{@patient_appointment.id}"
    @clinician_profile_link = "#{Rails.application.credentials.host_url}/find-care/booking/provider/#{@clinician.first_name.downcase}-#{@clinician.last_name.downcase}-#{@clinician.id}"
    @google_map_link = google_map_link(@patient_appointment.clinician_address)

    # Massachusetts logic
    @telehealth_text = [139414,147611].include?(@clinician.license_key) ? "You will receive a link to join your virtual visit in your appointment reminder" : "Use this link to access your virtual session"
    @telehealth_link = [139414,147611].include?(@clinician.license_key) ? "" :  @clinician.telehealth_url
    @waiting_room_text = [139414,147611].include?(@clinician.license_key) ? "" :  "Join waiting room"
    @telehealth_link = @clinician.telehealth_url.blank? && [139414,147611].exclude?(@clinician.license_key) ? "#{Rails.application.credentials.host_url}/telehealth-url-error/?patient_appointment_id=#{@patient_appointment.id}" : @clinician.telehealth_url

    @clinician_name = @clinician.full_name
    @clinician_name = @clinician_name + ", #{@clinician.license_type}"  if @clinician.license_type.present?
    attachments['event.ics'] = { :mime_type => 'text/calendar', content: @patient_appointment.icalendar.to_ical }

    @phreesia_enabled = Phreesia.find_by(license_key: @clinician.license_key).present?

    mail(to: @patient.account_holder.confirmation_email, subject: 'LifeStance Appointment Confirmation')
  end

  private

  def google_map_link(appt_address)
    map_link = "https://www.google.com/maps/search/?api=1&query="
    address_params = [appt_address.address_line1, appt_address.city, appt_address.state, appt_address.postal_code].join(", ")
    map_link = map_link + ERB::Util.url_encode(address_params)
  end

  def attach_images
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/emails/logo.png")
    attachments.inline['building_icon.png'] = File.read("#{Rails.root}/app/assets/images/emails/building_icon.png")
    attachments.inline['video_icon.png'] = File.read("#{Rails.root}/app/assets/images/emails/video_icon.png")
    attachments.inline['calendar_icon.png'] = File.read("#{Rails.root}/app/assets/images/emails/calendar_icon.png")
    attachments.inline['clipboard_icon.png'] = File.read("#{Rails.root}/app/assets/images/emails/clipboard_icon.png")
    attachments.inline['clock_icon.png'] = File.read("#{Rails.root}/app/assets/images/emails/clock_icon.png")
    attachments.inline['comments_icon.png'] = File.read("#{Rails.root}/app/assets/images/emails/comments_icon.png")
    attachments.inline['computer_icon.png'] = File.read("#{Rails.root}/app/assets/images/emails/computer_icon.png")
    attachments.inline['facebook.png'] = File.read("#{Rails.root}/app/assets/images/emails/Vector-fb.png")
    attachments.inline['linkedin.png'] = File.read("#{Rails.root}/app/assets/images/emails/Vector-in.png")
    attachments.inline['instagram.png'] = File.read("#{Rails.root}/app/assets/images/emails/Vector-insta.png")
    attachments.inline['twitter.png'] = File.read("#{Rails.root}/app/assets/images/emails/Vector-twitter.png")
    attachments.inline['phone.png'] = File.read("#{Rails.root}/app/assets/images/emails/phone.png")
    attachments.inline['credit_card.png'] = File.read("#{Rails.root}/app/assets/images/emails/credit_card.png")
  end

  def intake_phone_number(clinician_state)
    support_number = SupportDirectory.find_by(license_key: @office_key, state: clinician_state)&.intake_call_in_number || "(Unavailable)"
    support_number = "(312) 761-8365" if @patient.referral_source.present? && @patient.referral_source == "PPP"
    support_number
  end
end
