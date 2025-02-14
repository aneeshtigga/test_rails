class ClinicianLocationMart < DataWarehouse
  self.table_name = "data_source_ror.vw_location_mart"
  self.table_name = "clinician_location_marts" if Rails.env.development? || Rails.env.test?

  scope :with_clinician_id, ->(clinician_id) { where(clinician_id: clinician_id) }

  scope :with_valid_location, -> { where.not(location: nil, city: nil, state: nil, clinician_id: nil) }

  def location_info
    {
      office_key: license_key,
      primary_location: primary_location,
      facility_name: facility_name,
      facility_id: facility_id,
      apt_suite: apt_suite,
      address_line1: location,
      postal_code: zip_code,
      city: city,
      state: state,
      area_code: area_code,
      country_code: country_code,
      provider_id: clinician_id,
      deleted_at: deleted_at,
      cbo: cbo
    }
  end

  def clinician_location_keys
    {
      office_key: license_key,
      facility_id: facility_id,
      provider_id: clinician_id,
      cbo: cbo
    }
  end

  def deleted_at
    is_active == 1 ? nil : Time.now.utc
  end
end
