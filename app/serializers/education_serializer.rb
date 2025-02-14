class EducationSerializer < ActiveModel::Serializer
  attributes :id, :university,:state, :city, :country, :reference_type, :degree, :graduation_year
end
