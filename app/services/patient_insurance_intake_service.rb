class PatientInsuranceIntakeService
  def initialize(patient:, insurance_params:)
    @patient = patient
    @insurance_params = insurance_params
  end

  def save!
    InsuranceCoverage.transaction do
      if policy_holder_self?
        @responsible_party = patient.account_holder.responsible_party
        @responsible_party.intake_address = IntakeAddress.create!(address_params)
        @responsible_party.save!
      else
        @responsible_party = ResponsibleParty.find_by(
          'LOWER(first_name) = ? AND LOWER(last_name) = ? AND date_of_birth = ? AND LOWER(email) = ?',
          responsible_party_params["first_name"].downcase,
          responsible_party_params["last_name"].downcase,
          # Sanitizing DOB for DB search
          responsible_party_dob,
          responsible_party_params["email"].downcase
        )
          unless @responsible_party.present?
            @responsible_party ||= ResponsibleParty.create!(responsible_party_params)
            @responsible_party.intake_address = IntakeAddress.create!(address_params)
          end
        if @insurance_params["is_sso"] == true
          amd_responsible_party_id = nil
          amd_responsible_party = patient.client.responsible_parties.lookup_responsible_party(amd_responsible_party_lookup_params)
          amd_responsible_party_id = amd_responsible_party&.id
          if amd_responsible_party_id.nil?
            amd_responsible_party = patient.client.responsible_parties.add_responsible_party(amd_responsible_party_params)
            amd_responsible_party_id = amd_responsible_party["@id"]&.gsub(/\D/, "")
          else
            amd_responsible_party_id = amd_responsible_party_id&.gsub(/\D/, "")
          end
          raise "Responsible party amd api fail" if amd_responsible_party_id.blank?
          @responsible_party.amd_id = amd_responsible_party_id
          @responsible_party.amd_updated_at = Time.now
        end
        # As this is an update we don't need to validate duplications
        @responsible_party.skip_dup_validation = true
        @responsible_party.save!
      end

      insurance_coverage = if patient.insurance_coverages.present?
        patient.insurance_coverages.update(insurance_coverage_params)
                           else
        patient.insurance_coverages.create!(insurance_coverage_params)
                           end

      patient.insurance_coverages
    rescue StandardError => e
      ErrorLogger.report(e)
      raise e.message
    end
  end

  private

  attr_reader :patient, :insurance_params, :responsible_party

  def remove_previous_records
    patient.insurance_coverage&.destroy
  end

  def has_different_policy_holder?
    insurance_params["policy_holder"].present?
  end

  def has_different_address?
    insurance_params["address"].present?
  end

  def responsible_party_params
    if policy_holder_self? || !has_different_policy_holder?
      patient.slice(
        :first_name,
        :last_name,
        :date_of_birth,
        :gender
      ).merge(email: patient.account_holder.email)
    else
      insurance_params["policy_holder"]
    end
  end

  def address_params
    if has_different_address?
      insurance_params["address"].merge(intake_addressable: @responsible_party)
    else
      raise StandardError, "Patient address not found. Please update patient address" if patient.intake_address.nil?

      patient.intake_address.slice(
        :address_line1,
        :address_line2,
        :city,
        :state,
        :postal_code
      ).merge(intake_addressable: @responsible_party)
    end
  end

  def policy_holder_self?
    insurance_params["primary_policy_holder"] == "self"
  end

  def amd_responsible_party_lookup_params
    {
      first_name: responsible_party_params["first_name"],
      last_name: responsible_party_params["last_name"],
      date_of_birth: responsible_party_dob,
      email: responsible_party_email,
      gender: responsible_party_gender
    }
  end

  def amd_responsible_party_params
    {
      patient: {
        respparty: responsible_party_name,
        name: responsible_party_name,
        sex: responsible_party_gender,
        relationship: relationship,
        hipaarelationship: hipaarelationship,
        dob: responsible_party_dob,
        ssn: nil,
        chart: "AUTO",
        profile: responsible_party_provider_id,
        finclass: "",
        deceased: "",
        title: "",
        maritalstatus: "",
        insorder: "",
        employer: "",
        address: {
          zip: address_params["postal_code"],
          city: address_params["city"],
          state: address_params["state"],
          address1: address_params["address_line2"], # AMD is reversed for addresses
          address2: address_params["address_line1"]
        },
        contactinfo: {
          homephone: "",
          officephone: "",
          officeext: "",
          otherphone: patient.phone_number,
          othertype: "C",
          email: responsible_party_email
        }
      },
      respparty: {
        '@name': responsible_party_name,
        '@accttype': "4",
        '@sex': responsible_party_gender,
        '@dob': responsible_party_dob
      }
    }
  end

  def relationship
    patient.policy_holder_mapping(responsible_party_relation)[:relationship]
  end

  def hipaarelationship
    patient.policy_holder_mapping(responsible_party_relation)[:hipaarelationship]
  end

  def responsible_party_name
    "#{responsible_party_params['last_name']},#{responsible_party_params['first_name']}"
  end

  def responsible_party_gender
    case responsible_party_params["gender"].downcase
    when "male"
      "M"
    when "female"
      "F"
    else
      "U"
    end
  end

  def responsible_party_relation
    insurance_params["primary_policy_holder"].downcase
  end

  def responsible_party_dob
    input_date = responsible_party_params["date_of_birth"]
    if input_date.match(/^\d{4}-\d{2}-\d{2}$/)
      date = input_date # Return as-is if already in YYYY-MM-DD format
    else
      # Otherwise, parse the MM/DD/YYYY format and convert it
      date = Date.strptime(input_date, "%m/%d/%Y").strftime("%Y-%m-%d")
    end
    date
  end

  def responsible_party_email
    responsible_party_params["email"]
  end

  def responsible_party_provider_id
    patient.profile_id
  end

  def get_facility_accepted_insurance_id
    FacilityAcceptedInsurance.with_insurance_name(insurance_params["insurance_carrier"]).with_clinician_address(
      insurance_params["provider_id"], insurance_params["license_key"], insurance_params["facility_id"]
    ).last.try(:id)
  end

  def insurance_coverage_params
    {
      facility_accepted_insurance_id: get_facility_accepted_insurance_id,
      company_name: insurance_params["insurance_carrier"],
      member_id: insurance_params["member_id"],
      mental_health_phone_number: insurance_params["mental_health_phone_number"],
      relation_to_policy_holder: responsible_party_relation,
      policy_holder: @responsible_party
    }
  end
end
