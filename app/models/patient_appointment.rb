require "icalendar"

class PatientAppointment < ApplicationRecord
  validates :cbo, :license_key, presence: true
  belongs_to :patient
  belongs_to :appointment
  belongs_to :clinician
  belongs_to :clinician_address

  enum status: { "booked" => 0, "cancelled" => 1 }

  delegate :start_time, to: :appointment
  delegate :end_time, to: :appointment
  delegate :duration, to: :appointment
  delegate :type_of_care, to: :appointment

  delegate :in_office?, to: :appointment

  def in_office_or_virtual?
    appointment.in_office? || appointment.both?
  end

  def icalendar
    cal = Icalendar::Calendar.new
    cal.event do |event|
      event.dtstart = start_time.in_time_zone(clinician_timezone)
      event.dtend = end_time.in_time_zone(clinician_timezone)
      event.summary = "LifeStance Appointment"
    end
    cal
  end

  def is_cancellable?
    appointment_date_time = appointment.start_time.in_time_zone(clinician_timezone)
    allowed_cancellation_appointment_time = (appointment_date_time - BUSINESS_HOURS[appointment_date_time.strftime("%a")].to_i.days)
    allowed_cancellation_appointment_time > (Time.now.in_time_zone(clinician_timezone))
  end

  def appointment_occurred_in_past?
    appointment_date_time = appointment.start_time.in_time_zone(clinician_timezone)
    appointment_date_time < (Time.now.in_time_zone(clinician_timezone))
  end

  def support_info
    SupportDirectory.find_by(license_key: clinician_address.office_key, state: clinician_address.state)
  end

  def marketing_referral_phone
    # When marketing referral is saved from URL the selected_slot_info marketingReferralPhone is not empty
    unless selected_slot_info_referral.empty?
      MarketingReferral.find_by(amd_marketing_referral: patient.referral_source)&.phone_number
    end
  end

  def selected_slot_info_referral
    patient.account_holder.selected_slot_info.dig("preferences", "marketingReferralPhone")
  end

  def clinician_timezone
    postal_code = appointment.clinician_address.postal_code
    postal_code_data = PostalCode.find_by(zip_code: postal_code)
    postal_code_data.present? ? postal_code_data.time_zone : "UTC"
  end
end
