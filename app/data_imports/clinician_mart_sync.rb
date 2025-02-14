class ClinicianMartSync

  def initialize
    @clinicians_count = 0
    @created_languages_count = 0
    @created_license_types_count = 0
  end

  def self.import_data(time_since: Time.zone.now - 1.day)
    new.import_data(time_since: time_since)
  end

  def import_data(time_since: nil)
    clinicians_add_update_attempted_count = 0
    clinician_marts_data = clinician_marts(time_since)
    @clinicians_count = clinician_marts_data.count
    create_language(clinician_marts_data)
    create_license_types(clinician_marts_data)
    clinician_marts_data.pluck(:clinician_id, :license_key).each do |provider_id, license_key|
      ClinicianUpdaterWorker.perform_async(provider_id, license_key)
      clinicians_add_update_attempted_count += 1
    end

    {
      clinicians_count: @clinicians_count,
      clinicians_add_update_attempted_count: clinicians_add_update_attempted_count,
      created_languages: @created_languages_count,
      created_license_types: @created_license_types_count
    }
  end

  private

  def clinician_marts(time_since)
    if time_since.present?
      ClinicianMart.where("load_date > ?", time_since)
    else
      ClinicianMart.all
    end
  end

  def inactive_clinician_provider_ids
    clinician_mart_provider_ids = ClinicianMart.pluck(:clinician_id)

    Clinician.where.not(provider_id: clinician_mart_provider_ids).pluck(:provider_id)
  end

  def create_language(clinician_marts)
    clinician_marts.map { |x| x.languages.to_s.split(",") }.flatten.uniq.each do |language|
      language = Language.find_or_initialize_by(name: language.squish)
      unless language.persisted?
        language.save
        @created_languages_count += 1
      end
    end
  end

  def create_expertise(clinician_marts)
    clinician_marts.map { |x| x.expertise.to_s.split(",") }.flatten.uniq.each do |expertise|
      Expertise.find_or_create_by(name: expertise.squish)
    end
  end

  def create_license_types(clinician_marts)
    clinician_marts.map { |x| x.license_type.to_s.split(",") }.flatten.uniq.each do |license_type|
      license_type = LicenseType.find_or_initialize_by(name: license_type.squish)
      unless license_type.persisted?
        license_type.save
        @created_license_types_count += 1
      end
    end
  end
end
