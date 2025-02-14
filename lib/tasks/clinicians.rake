namespace :clinicians do
  desc "Find duplicate clinicians"
  task duplicates: :environment do
    require 'csv'

    puts "start time #{Time.zone.now}"
    csv_string = CSV.generate do |csv|
      csv << [
        "id", "provider_id", "npi", "license_key", "first_name", "last_name", "clinician_type", "patient_appointments",
        "patient_appointment_ids", "clinician_languages", "clinician_language_ids",
        "clinician_special_cases", "clinician_special_case_ids", "clinician_expertises", "clinician_expertise_ids",
        "clinician_concerns", "clinician_concern_ids", "clinician_interventions", "clinician_intervention_ids",
        "clinician_populations", "clinician_population_ids", "clinician_license_types", "clinician_license_type_ids",
        "type_of_cares", "type_of_care_ids", "facility_accepted_insurances", "facility_accepted_insurance_ids",
        "clinician_addresses", "clinician_addresse_ids", "educations", "education_ids", "clinician_accepted_ages",
        "clinician_accepted_age_ids",
      ]

      Clinician.duplicates.each do |clinician_data|
        clinicians = Clinician.where(
          provider_id: clinician_data["provider_id"],
          npi: clinician_data["npi"],
          license_key: clinician_data["license_key"],
          deleted_at: nil
        )
        clinicians.each do |clinician|
          csv << [
            clinician.id,
            clinician.provider_id,
            clinician.npi,
            clinician.license_key,
            clinician.first_name,
            clinician.last_name,
            clinician.clinician_type,
            clinician.patient_appointments.count,
            clinician.patient_appointments.ids,
            clinician.clinician_languages.count,
            clinician.clinician_languages.ids,
            clinician.clinician_special_cases.count,
            clinician.clinician_special_cases.ids,
            clinician.clinician_expertises.count,
            clinician.clinician_expertises.ids,
            clinician.clinician_concerns.count,
            clinician.clinician_concerns.ids,
            clinician.clinician_interventions.count,
            clinician.clinician_interventions.ids,
            clinician.clinician_populations.count,
            clinician.clinician_populations.ids,
            clinician.clinician_license_types.count,
            clinician.clinician_license_types.ids,
            clinician.type_of_cares.count,
            clinician.type_of_cares.ids,
            clinician.facility_accepted_insurances.count,
            clinician.facility_accepted_insurances.ids,
            clinician.clinician_addresses.count,
            clinician.clinician_addresses.ids,
            clinician.educations.count,
            clinician.educations.ids,
            clinician.clinician_accepted_ages.count,
            clinician.clinician_accepted_ages.ids,
          ]
        end # end clinicians.each
      end
    end # end CSV.generate

    puts csv_string
    puts "end time #{Time.zone.now}"
  end
end
