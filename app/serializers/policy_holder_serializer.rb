class PolicyHolderSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :date_of_birth, :gender
  has_one :address, serializer: IntakeAddressSerializer

  def address
    object.intake_address
  end
end