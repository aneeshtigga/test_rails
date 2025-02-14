class ClinicianEducation < DataWarehouse
  self.table_name = "data_source_ror.vw_education"
  self.table_name = "clinician_educations" if Rails.env.development? || Rails.env.test?

  def education_data
    {
      degree: degree,
      reference_type: referencetype,
      graduation_year: graduationyear,
      university: universityname,
      city: universitycity,
      state: universitystate,
      country: universitycountry
    }
  end
end
