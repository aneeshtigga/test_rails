class LicenseKeyBlockoutRule
  def self.passes_for?(appointment)
    clinician = appointment.clinician

    # must comply with license key blockout hours
    block_out_hours = LicenseKeyRule.block_out_hours_for_license_key(clinician.license_key)
    days_to_skip = ClinicianAvailability.days_to_skip(block_out_hours)
    earliest_start = Time.now + block_out_hours.hours + (days_to_skip*24).hours

    appointment.start_time > earliest_start
  end
end
