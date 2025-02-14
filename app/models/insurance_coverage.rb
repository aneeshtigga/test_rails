class InsuranceCoverage < ApplicationRecord
  belongs_to :patient
  belongs_to :policy_holder, class_name: "ResponsibleParty"
  belongs_to :facility_accepted_insurance, optional: true

  validates :company_name, presence: true
  validates :member_id, presence: true
  validates :relation_to_policy_holder, presence: true
  validates :relation_to_policy_holder,
            inclusion: { in: %w[self spouse parent_guardian parent_spouse child other] }
  has_one_attached :front_card
  has_one_attached :back_card

  def front_card_url
    if front_card.attached?
      ActiveStorage::Current.set(host: Rails.application.credentials.host_url) do
        front_card.url
      end
    end
  end

  def back_card_url
    if back_card.attached?
      ActiveStorage::Current.set(host: Rails.application.credentials.host_url) do
        back_card.url
      end
    end
  end

  def create_amd_insurance_data
    insurance = patient.client.insurances.add_insurance(insurance_params)

    amd_insurance_id = insurance["@id"]&.gsub(/\D/, "")

    raise insurance["Fault"]["detail"]["description"] || "Insurance created amd api fail" if amd_insurance_id.blank?
    self.update!(amd_id: amd_insurance_id, amd_updated_at: Time.zone.now)
  end

  def insurance_params
    { patient_id: patient.amd_patient_id,
      insurance_plan: { id: "", begindate: "", enddate: "",
                        carrier: try(:facility_accepted_insurance).try(:insurance).try(:amd_carrier_id),
                        subscriber: try(:policy_holder).try(:amd_id),
                        subscribernum: member_id,
                        hipaarelationship: hipaarelationship,
                        relationship: relationship } }
  end

  def relationship
    patient.policy_holder_mapping(relation_to_policy_holder)[:relationship]
  end

  def hipaarelationship
    patient.policy_holder_mapping(relation_to_policy_holder)[:hipaarelationship]
  end
end
