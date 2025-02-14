class TypeOfCareSerializer < ActiveModel::Serializer
  attributes :id, :amd_license_key, :in_person_visit, :virtual_or_video_visit, :amd_appointment_type
  attributes :type_of_care, :age_group, :facility_id
end

