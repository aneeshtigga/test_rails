class OtherClinicianDetailsSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :provider_id,:credentials, :about, :type, :photo, :facility_location

  has_many :expertises

  def credentials
    object.license_type
  end

  def about
    object.about_the_provider
  end

  def type
    object.mapped_clinician_type
  end

  def photo
    object.presigned_photo
  end

  def facility_location
    object.clinician_addresses.with_active_office_keys.most_available.first
  end
end
