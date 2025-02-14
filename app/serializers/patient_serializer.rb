class PatientSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :preferred_name, :date_of_birth, :phone_number, :referral_source,
    :account_holder_relationship, :pronouns, :about, :special_case_id, :search_filter_values,
    :credit_card_on_file_collected, :intake_status, :account_holder_id, :gender, :gender_identity, :amd_patient_id

  has_many :insurance_coverages, serializer: InsuranceCoverageSerializer
  has_one :address, serializer: IntakeAddressSerializer

  def address
    object.intake_address
  end
end
