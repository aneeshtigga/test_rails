class AppointmentMonitor
  HOURS_THRESHOLD = {
    business_hours_weekday: Rails.application.credentials.dig(:appointment_monitor, :business_hours_weekday),
    non_business_hours_weekday: Rails.application.credentials.dig(:appointment_monitor, :non_business_hours_weekday),
    business_hours_weekend: Rails.application.credentials.dig(:appointment_monitor, :business_hours_weekend),
    non_business_hours_weekend: Rails.application.credentials.dig(:appointment_monitor, :non_business_hours_weekend),
  }

  def self.within_threshold?
    new.within_threshold?
  end

  def self.threshold
    new.threshold
  end

  def within_threshold?
    (DateTime.now.utc - last_appointment_created) / 1.hours < threshold
  end

  def threshold
    if within_business_hour? && week_day?
      threshold = HOURS_THRESHOLD[:business_hours_weekday]
    elsif !within_business_hour? && week_day?
      threshold = HOURS_THRESHOLD[:non_business_hours_weekday]
    elsif within_business_hour? && weekend?
      threshold = HOURS_THRESHOLD[:business_hours_weekend]
    else
      threshold = HOURS_THRESHOLD[:non_business_hours_weekend]
    end
  end

  private

  # Hours within 9am - 5pm EST
  def within_business_hour?
    now = DateTime.now.in_time_zone("America/New_York")
    now.hour.between?(9, 17)
  end

  def week_day?
    !weekend?
  end

  def weekend?
    today = DateTime.now.utc
    today.saturday? || today.sunday?
  end

  def last_appointment_created
    PatientAppointment.order(created_at: :desc).first.created_at
  end
end