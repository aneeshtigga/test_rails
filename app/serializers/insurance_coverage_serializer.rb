class InsuranceCoverageSerializer < ActiveModel::Serializer
  attributes :id, :company_name, :member_id, :relation_to_policy_holder, :policy_holder_id,
             :mental_health_phone_number, :patient_id, :policy_holder, :amd_id

  def policy_holder
    ActiveModelSerializers::SerializableResource.new(object.policy_holder, each_serializer: PolicyHolderSerializer)
  end
end
