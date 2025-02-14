class AddMarketingReferralService
  def initialize(patient)
    @patient = patient
  end

  # Options for referral source:
  # ALEXANDRIA, BEHAVIORAL HEALTH DR, CCRM FERTILITY, FRIEND OR FAMILY, GALILEO, HOSPITAL, PRIMARY CARE DOCTOR,
  # OB/GYN, PAIN MGMT DOCTOR, PSYCHOLOGY TODAY, QUARTET, SEARCH ENGINE, SOCIAL MEDIA, ZOCDOC
  def amd_source_id
    return if @patient.referral_source.blank?
    referrals.lookup_ref_source(@patient.referral_source)
  end

  def push_referral
    source_id = amd_source_id

    raise "No marketing referral source found in AMD for: #{@patient.referral_source}, patient id: #{@patient.id}" if source_id.blank?

    referral_id = referrals.add_patients_referral_source(@patient.amd_patient_id, source_id)
    @patient.update(marketing_referral_id: referral_id)
  end

  def referrals
    @referrals ||= client.referrals
  end

  def client
    @client ||= Amd::AmdClient.new(office_code: @patient.office_code)
  end

  def get_mapped_source
    {
      'Alexandria': "ALEXANDRIA",
      'Behavioral Health Provider (Psychiatrist, Therapist, School Counselor, Higher Level of Care)': "BEHAVIORAL HEALTH DR",
      'CCRM Fertility': "CCRM FERTILITY",
      'Friend or family member': "FRIEND OR FAMILY",
      'Galileo': "GALILEO",
      'Hospital': "HOSPITAL",
      'My primary care provider': "PRIMARY CARE DOCTOR",
      'OBGYN': "OBGYN",
      'Pain Management Doctor': "PAIN MGMT DOCTOR",
      'PsychologyToday': "PSYCHOLOGY TODAY",
      'Quartet': "QUARTET",
      'Search engine (Google, Bing, etc.)': "SEARCH ENGINE",
      'Social media': "SOCIAL MEDIA",
      'Zocdoc': "ZOCDOC",
    }.as_json
  end
end
