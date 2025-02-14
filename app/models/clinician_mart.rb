class ClinicianMart < DataWarehouse
  self.table_name = "data_source_ror.vw_clinician_mart"
  self.table_name = "vw_clinician_mart" if Rails.env.development? || Rails.env.test?

  scope :active, -> { where(is_active: true) }

  def personal_info 
    {
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      clinician_type: clinician_type,
      license_type: license_type,
      about_the_provider: about_the_provider,
      in_office: in_office,
      video_visit: virtual_visit,
      manages_medication: manages_medication,
      ages_accepted: ages_accepted,
      provider_id: clinician_id,
      npi: npi,
      telehealth_url: telehealth_url,
      gender: gender,
      pronouns: pronouns,
      license_key: license_key,
      photo: photo,
      cbo: cbo,
      supervised_clinician: supervised_clinician,
      supervisory_disclosure: supervisory_disclosure,
      supervisory_type: supervisory_type,
      supervising_clinician: supervising_clinician,
      display_supervised_msg: display_supervised_msg
    }
  end

  def location_info
    {
      primary_location: primary_location,
      address_line1: location,
      postal_code: zip_code,
      city: city,
      state: state,
      facility_name: facility_name,
      facility_id: facility_id,
      apt_suite: apt_suite,
      country_code: country_code,
      area_code: area_code,
    }
  end

  def get_uniq_identifier
    {
      provider_id: clinician_id,
      license_key: license_key
    }
  end
end
