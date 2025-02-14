class AccountHolderSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :date_of_birth, :gender, :gender_identity, :phone_number, :source,
    :receive_email_updates, :search_filter_values, :email_verified, :pronouns, :about, :account_holder_patient_id

  def account_holder_patient_id
    object.self_patient.id
  end
end