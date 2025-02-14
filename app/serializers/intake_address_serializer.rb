class IntakeAddressSerializer < ActiveModel::Serializer
  attributes :id, :address_line1, :address_line2, :city, :state, :postal_code
end