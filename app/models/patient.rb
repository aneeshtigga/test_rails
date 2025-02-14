class Patient < ApplicationRecord
  belongs_to :special_case, optional: true
  belongs_to :account_holder

  has_many :patient_disorders
  has_many :concerns, through: :patient_disorders
  has_many :populations, through: :patient_disorders
  has_many :interventions, through: :patient_disorders
  has_one :intake_address, as: :intake_addressable
  has_many :insurance_coverages
  has_many :policy_holders, through: :insurance_coverages
  has_many :patient_appointments, dependent: :destroy
  has_many :clinicians, through: :patient_appointments
  has_many :appointments, through: :patient_appointments
  has_one :emergency_contact

  accepts_nested_attributes_for :patient_disorders

  enum account_holder_relationship: { self: 0, child: 1 }

  enum intake_status: { patient_profile_info: 0,
                        prepare_for_visit: 1,
                        address: 2,
                        referring_provider_data: 3,
                        email_verification_sent: 4,
                        insurance: 5,
                        credit_card_information: 6,
                        confirmation_screen: 7 }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :account_holder_relationship, presence: true
  validates :preferred_name, format: { with: /\A[a-zA-Z0-9\s]+\z/, message: "only allows letters and numbers" }, allow_blank: true
  validate :existing_amd_patient, on: :create
  validates :first_name, uniqueness: { scope: [:last_name, :date_of_birth, :email], message: "Patient already exists" }, unless: :skip_dup_validation

  before_validation :sanitize_dob
  before_validation :set_office_code
  before_create :set_profile_id
  after_create :create_responsible_party
  delegate :email, to: :account_holder

  attr_accessor :exists_in_amd, :skip_dup_validation

  def client
    @client ||= Amd::AmdClient.new(office_code: office_code)
  end

  def policy_holder_mapping(type)
    if type == "self"
      relationship_code = account_holder_relationship.to_sym
    elsif (account_holder_relationship == type) && account_holder_relationship == "child"
      relationship_code = :self
    else
      relationship_code = type.to_sym
    end

    relationships = { self: "1", spouse: "2", child: "3", other: "4" }

    hipaa_relalationship_codes = {
      self: "18",
      spouse: "01",
      child: "19",
      other: "G8"
    }

    {
      relationship: relationships[relationship_code].presence || relationships[:other],
      hipaarelationship: hipaa_relalationship_codes[relationship_code].presence || hipaa_relalationship_codes[:other]
    }
  end

  def hipaa_relationship_codes(type)
    type = type.titleize
    hipaa_relationship = HipaaRelationshipCode.find_by(description: type)
    hipaa_relationship&.code
  end

  def relation_type_code
    relationship_types[self.account_holder_relationship]
  end

  def relationship_types
    { self: 1, spouse: 2, child: 3, other: 4 }.with_indifferent_access
  end

  def patient_state
    clinician_address_id = self.search_filter_values["clinician_address_id"]
    zipcode = ClinicianAddress.find_by(id: clinician_address_id)&.postal_code
    state_abbr = PostalCode.find_by_zip_code(zipcode)&.state
    state_abbr
  end

  def patient_location
    address = self.intake_address&.full_address
    address.present? ? address : self.search_filter_values["zip_codes"]
  end

  def amd_save_ccof(credit_card_params)
    credit_card_params = credit_card_params.with_indifferent_access
    return false unless credit_card_params
    return false unless credit_card_params["creditCardToken"]

    credit_card_params["responsiblePartyId"] = account_holder&.responsible_party&.amd_id

    self.update(credit_card_on_file_collected: client.transactions.add_credit_card(credit_card_params))
    credit_card_on_file_collected
  end

  def amd_has_ccof?
    client.transactions.credit_card_on_file?(account_holder.responsible_party&.amd_id)
  end

  def create_amd_patient
    return if amd_patient_id.present?

    patient = client.patients.add_patient(patient_params)
    
    amd_patient_id = patient["@id"]&.gsub(/\D/, "")

    # abort patient creation if amd patient was not created
    raise patient["Fault"]["detail"]["description"] || "failed to save amd patient: #{patient}" if amd_patient_id.nil?

    amd_respparty_id = patient["@respparty"]&.gsub(/\D/, "")

    if account_holder_relationship == "self"
      account_holder.responsible_party.update!(
        amd_id: amd_respparty_id,
        amd_updated_at: Time.now
      )
    end

    self.update!(amd_patient_id: amd_patient_id, amd_updated_at: Time.now)
  end

  def create_responsible_party
    if account_holder_relationship == "self"
      reps_party = ResponsibleParty.find_by(
        'LOWER(first_name) = ? AND LOWER(last_name) = ? AND date_of_birth = ? AND LOWER(gender) = ? AND LOWER(email) = ?',
        first_name.downcase,
        last_name.downcase,
        date_of_birth,
        gender.downcase,
        email.downcase
      )
      unless reps_party.present?
        account_holder.create_responsible_party!(
          first_name: first_name,
          last_name: last_name,
          date_of_birth: date_of_birth,
          gender: gender,
          email: email
        )
      end
    end
  end

  def post_marketing_referral
    return if marketing_referral_id.present? || referral_source.blank?

    PatientReferralSourceWorker.perform_async(id) if amd_patient_id.present?
  end

  def display_name
    preferred_name.present? ? preferred_name : first_name
  end

  def amd_patient
    # If the lookup is for a child we avoid sending :email
    @amd_patient ||= client.patients.lookup_patient(account_holder_relationship == "child" ? lookup_params.except(:email) : lookup_params)
  end
  
  private

  def existing_amd_patient
    return office_code_error if office_code.blank?
    
    return patient_exists_in_amd_error if amd_patient.present?
  end


  def lookup_params
    {
      first_name: first_name,
      last_name: last_name,
      date_of_birth: date_of_birth.to_date.strftime("%m/%d/%Y"),
      gender: gender,
      email: email,
    }
  end

  def patient_params
    Amd::Data::AmdPatient.new(self).params
  end

  def patient_exists_in_amd_error
    errors.add(:base, "Patient already exists in AMD")
    self.amd_patient_id = amd_patient.id.gsub(/\D/, "")
    self.exists_in_amd = true
  end

  def office_code_error
    errors.add(:office_code, "was not provided")
  end

  def set_office_code
    self.office_code = select_office_code
  end

  def select_office_code
    return office_code if office_code.present?

    lookup_office_key
  end

  def lookup_office_key
    return if search_filter_values.blank?

    clinician_address_id = search_filter_values["clinician_address_id"]
    clinician_address = ClinicianAddress.find_by(id: clinician_address_id)
    clinician_address&.office_key
  end

  def set_profile_id
    provider_id = self.provider_id
    clinician_address_id = self.search_filter_values["clinician_address_id"]

    facility_id = ClinicianAddress.find_by(id: clinician_address_id)&.facility_id
    profile_id = ClinicianAvailability.where(provider_id: provider_id, facility_id: facility_id).first&.profile_id

    self.profile_id = profile_id
  end

  def sanitize_dob
    self.date_of_birth = Date.strptime(date_of_birth, "%m/%d/%Y")
  rescue StandardError
    nil
  end
end
