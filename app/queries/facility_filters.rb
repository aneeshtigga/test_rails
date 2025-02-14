class FacilityFilters
  def self.get_locations(filters = {})
    addresses = ClinicianAddress.active
    addresses = addresses.with_zip_code(filters[:zip_code]) if filters[:zip_code].present?
    addresses = addresses.type_of_care_criteria(filters[:type_of_care]) if filters[:type_of_care].present?
    addresses.select(
      :facility_name,
                :facility_id,
                :address_line1,
                :address_line2,
                :city,
                'substr(cast(latitude as text), 1, 6)::float as latitude', 'substr(cast(longitude as text), 1, 6)::float as longitude'
    )
             .distinct
             .order(:city, :address_line1)
  end 
end
