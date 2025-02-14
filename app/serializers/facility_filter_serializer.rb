class FacilityFilterSerializer < ActiveModel::Serializer
  attributes :address_line1, :address_line2, :city, :facility_id, :facility_name, :distance_in_miles

  def distance_in_miles
    ClinicianAddress.distance_between_two_points(
      [@instance_options[:postal_code]&.as_json&.fetch("latitude").to_f,
       @instance_options[:postal_code]&.as_json&.fetch("longitude").to_f], [object.latitude.to_f, object.longitude.to_f]
    ) if @instance_options[:postal_code].present?
  end
end
