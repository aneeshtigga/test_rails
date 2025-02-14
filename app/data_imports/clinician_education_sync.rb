class ClinicianEducationSync
  def self.import_data
    Education.delete_all
    get_uniq_npis.each do |npi|
      CreateEducationsWorker.perform_async(npi)
    end
  end

  def self.create_data(npi)
    clinician = Clinician.find_by(npi: npi)
    unless clinician.nil?
      ClinicianEducation.where(npi: clinician.npi).each do |clinician_education|
        clinician.educations.create(clinician_education.education_data)
      end
    end
  end

  def self.get_uniq_npis
    ClinicianEducation.pluck("distinct npi")
  end
end
