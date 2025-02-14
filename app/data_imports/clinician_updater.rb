class ClinicianUpdater
  def self.add_or_update_clinician(provider_id:, license_key:)
    new(provider_id: provider_id, license_key: license_key).add_or_update_clinician
  end

  def initialize(provider_id:, license_key:)
    @provider_id = provider_id
    @license_key = license_key
    @update_languages = 0
    @update_expertises = 0
    @update_concerns = 0
    @update_interventions = 0
    @update_populations = 0
    @update_license_types = 0
  end

  def add_or_update_clinician
    check_dw_clinician

    begin
      Clinician.transaction do
        clinician.assign_attributes(dw_clinician.personal_info)

        update_languages(clinician, dw_clinician)
        update_expertises(clinician, dw_clinician)
        update_concerns(clinician, dw_clinician)
        update_interventions(clinician, dw_clinician)
        update_populations(clinician, dw_clinician)
        update_license_types(clinician, dw_clinician)

        unless dw_clinician.is_active?
          clinician.soft_delete
        else
          clinician.deleted_at = nil
        end

        clinician.save!

        {
          update_languages: @update_languages,
          update_expertises: @update_expertises,
          update_concerns: @update_concerns,
          update_interventions: @update_interventions,
          update_populations: @update_populations,
          update_license_types: @update_license_types,
        }
      end
    rescue StandardError => e
      ErrorLogger.report(e)
      Rails.logger.error "Error occured in add_or_update_clinician #{dw_clinician.personal_info} date: #{DateTime.now}"
      raise e
    end
  end

  private

  attr_reader :provider_id, :license_key

  def clinician
    @clinician ||= Clinician.find_or_initialize_by(provider_id: provider_id, license_key: license_key)
  end

  def dw_clinician
    @dw_clinician ||= ClinicianMart.find_by(clinician_id: provider_id, license_key: license_key)
  end

  def update_languages(clinician, dw_clinician)
    clinician.clinician_languages.map(&:mark_for_destruction)

    languages = if dw_clinician.languages.present?
                  dw_clinician.languages.split(",").map do |language|
                    Language.find_by(name: language.squish)
                  end
                else
                  []
                end

    clinician.languages = languages
    clinician.save!
    @update_languages = languages.size
  end

  def update_expertises(clinician, dw_clinician)
    clinician.clinician_expertises.map(&:mark_for_destruction)
    expertises = if dw_clinician.expertise.present?
                     dw_clinician.expertise.split(",").map do |expertise|
                       Expertise.find_by(name: expertise.squish)
                     end
                   else
                     []
                   end

    clinician.expertises = expertises.compact
    clinician.save!

    @update_expertises = expertises.compact.size
  end

  def update_interventions(clinician, dw_clinician)
    clinician.clinician_interventions.map(&:mark_for_destruction)
    inteventions = if dw_clinician.intervention.present?
                     dw_clinician.intervention.split(",").map do |intervention|
                       Intervention.find_by(name: intervention.squish)
                     end
                   else
                     []
                   end

    clinician.interventions = inteventions.compact
    clinician.save!

    @update_interventions = inteventions.compact.size
  end

  def update_populations(clinician, dw_clinician)
    clinician.clinician_populations.map(&:mark_for_destruction)
    populations = if dw_clinician.population.present?
                     dw_clinician.population.split(",").map do |population|
                       Population.find_by(name: population.squish)
                     end
                   else
                     []
                   end

    clinician.populations = populations.compact
    clinician.save!

    @update_populations = populations.compact.size
  end

  def update_license_types(clinician, dw_clinician)
    clinician.clinician_license_types.map(&:mark_for_destruction)
    license_types = if dw_clinician.license_type.present?
                      dw_clinician.license_type.split(",").map do |license_type|
                        LicenseType.find_by(name: license_type.squish)
                      end.compact
                    else
                      []
                    end

    clinician.license_types = license_types
    clinician.save!

    @update_license_types = license_types.size
  end

  def update_concerns(clinician, dw_clinician)
    clinician.clinician_concerns.map(&:mark_for_destruction)
    concerns = if dw_clinician.concern.present?
                     dw_clinician.concern.split(",").map do |concern|
                       Concern.find_by(name: concern.squish)
                     end
                   else
                     []
                   end

    clinician.concerns = concerns.compact
    clinician.save!

    @update_concerns = concerns.compact.size
  end

  def check_dw_clinician
    raise "Unable to find dw_clinician - provider_id: #{provider_id}, license_key: #{license_key}" unless dw_clinician

    raise "Clinician data error: #{dw_clinician.personal_info} date: #{DateTime.now}" if dw_clinician.first_name.blank?
  end
end
