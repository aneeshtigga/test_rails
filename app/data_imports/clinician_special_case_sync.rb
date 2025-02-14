class ClinicianSpecialCaseSync
  def self.import_data
    updated_clinician_count = 0
    ClinicianMart.where.not(special_cases: [nil, ""]).each do |dw_clinician|
      lfs_special_cases = get_lfs_special_cases(dw_clinician)
      clinician = Clinician.find_by(dw_clinician.get_uniq_identifier)

      UpdateClinicianSpecialCaseWorker.perform_async(clinician.id, lfs_special_cases)	if clinician.present?
      updated_clinician_count += 1
    end
    {
      updated_clinician_count: updated_clinician_count
    }
  end

  def self.update_special_cases(clinician_id, special_cases)
      clinician = Clinician.find(clinician_id)
      clinician.clinician_special_cases.map(&:mark_for_destruction)
      clinician.special_cases = SpecialCase.where(name: special_cases)
      clinician.save!
  rescue StandardError => e
      ErrorLogger.report(e)
      Rails.logger.error "Error occured in update_special_cases clinician_id: #{clinician_id} special_cases: #{special_cases}"
  end

  def self.get_lfs_special_cases(dw_clinician)
    special_cases = dw_clinician.special_cases.split(",").reject(&:empty?).map(&:strip)

    lfs_special_cases = special_cases.map do |special_case|
      specialcase = map_lfs_special_cases[special_case] || "None of the above"
    end
  end

  def self.map_lfs_special_cases
    {
      'Recently discharged from a psychiatric hospital': "Recently discharged from a psychiatric hospital",
      'Court Ordered Treatment': "Court-ordered treatment",
      'Workers Compensation': "Worker's compensation matter",
      'Parental Custody': "Parental custody matter",
      'Disability Paperwork': "Disability paperwork",
      'Current Legal Matter': "Current legal matter",
      'Currently experiencing suicidal thoughts': "Currently experiencing suicidal thoughts"
    }.as_json
  end
end
