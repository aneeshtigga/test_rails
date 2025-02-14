class SsoClinicianLocationSerializer < ActiveModel::Serializer
  attributes :id, :address_line1, :address_line2, :city, :state, :postal_code, :address_code, :office_key, :facility_id
  attributes :facility_name, :primary_location, :apt_suite, :area_code, :country_code, :distance_in_miles, :latitude, :longitude

  def distance_in_miles
    if @instance_options[:patient_location].present?
      latitude, longitude = @instance_options[:patient_location]
      object.distance_to_lat_lng(latitude, longitude)
    else
      nil
    end
  end
end
