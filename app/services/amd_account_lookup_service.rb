class AmdAccountLookupService
  def initialize(account_holder_params, office_code = nil)
    @account_holder_params = account_holder_params
    @office_code = office_code
  end

  def existing_accounts
    if amd_responsible_party.present?
      {
        responsible_party_patients: responsible_party_members,
      }
    else
      {
        responsible_party_patients: []
      }
    end
  rescue StandardError => e 
    ErrorLogger.report(e)
    raise e.message
  end

  def amd_search_for_patient
    first_name = account_holder_params[:first_name]
    last_name = account_holder_params[:last_name]
    date_of_birth = account_holder_params[:date_of_birth]
    patients = client.patients.lookup_patient_by_name(first_name, last_name)
    filtered_patients = patients.select do |patient|
      patient.first_name.to_s.casecmp(first_name.to_s).zero? &&
        patient.last_name.to_s.casecmp(last_name.to_s).zero? &&
        patient.date_of_birth.to_s == date_of_birth.to_s
    end
    
    filtered_patients.first
  end

  private

  attr_reader :account_holder_params

  def responsible_party_members
    resp = get_responsible_party_details

    if resp["resppartylist"]["respparty"]["familymemberlist"].present?
      records = [resp["resppartylist"]["respparty"]["familymemberlist"]["familymember"]].flatten
      records.map do |member_data|
        member = Amd::Data::FamilyMember.new(member_data)
        build_patient_attrs(member)
      end
    else
      []
    end
  end

  def build_patient_attrs(patient)
    # TODO: This needs office keys, and facilities ids not currently returned in amd apis
    {
      id: patient.id,
      first_name: patient.first_name,
      last_name: patient.last_name,
      chart: patient.chart,
      responsible_party: patient.responsible_party?,
      lfs_account_holder_id: lfs_account_holder_id(patient.id)
    }
  end

  def lfs_account_holder_id(patient_id)
    patient_id = patient_id.gsub("family","")
    Patient.find_by(amd_patient_id: patient_id)&.account_holder_id
  end

  def amd_responsible_party
    @amd_responsible_party ||= client.responsible_parties.lookup_responsible_party(resp_lookup_params)
  end

  def get_responsible_party_details
    @get_responsible_party_details ||= client.responsible_parties.get_responsible_party(amd_responsible_party.id)
  end

  def client
    @client ||= Amd::AmdClient.new(office_code: @office_code)
  end

  def resp_lookup_params
    {
      first_name: account_holder_params[:first_name],
      last_name: account_holder_params[:last_name],
      date_of_birth: account_holder_params[:date_of_birth],
      gender: account_holder_params[:gender],
      email: account_holder_params[:email]
    }
  end
end
