class AdvancedNoticeRule
  def self.passes_for?(appointment)
    # must be booked at least some business days in advance (see BUSINESS_DAYS)
    day_of_the_week = Time.now.utc.strftime("%a")
    multiplier = BUSINESS_DAYS[day_of_the_week].to_i
    block_out_hours = AVAILABILITY_BLOCK_OUT_DEFAULT * multiplier

    appointment.start_time >= (Time.now + block_out_hours.hours)
  end
end