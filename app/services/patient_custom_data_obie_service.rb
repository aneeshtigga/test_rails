class PatientCustomDataObieService < PatientCustomData
  def tab_code
    "OBIE"
  end

  def fieldvalue_by_name(name)
    if name.include?("Preferred Name")
      patient.preferred_name
    elsif name.include?("Pronouns")
      patient.pronouns.present? ? amd_pronoun_id[patient.pronouns] : nil
    elsif name.include?("Tell us about")
      patient.about
    elsif name.include?("Special Cases")
      patient.special_case.present? ? amd_special_case_id[patient.special_case.name] : nil
    elsif name.include?("Visit Reason")
      tab_text = ""
      tab_text << patient.concerns.pluck(:name).join(", ")

      patient.interventions.present? ? tab_text << ", " : nil
      tab_text << patient.interventions.pluck(:name).join(", ")

      patient.populations.present? ? tab_text << ", " : nil
      tab_text << patient.populations.pluck(:name).join(", ")
      
      tab_text
    end
  end

  def amd_pronoun_id
    {
      'She/her': 1,
      'He/him': 2,
      'They/them': 3,
      Other: 4,
      'Xe/xem': 5,
      'Ze/zir': 6,
      'Not represented here': 7,
      'Prefer not to say': 8
    }.as_json
  end

  def amd_special_case_id
    {
      'Recently discharged from a psychiatric hospital': 1,
      'Court-ordered treatment': 2,
      "Worker's compensation matter": 3,
      'Parental custody matter': 4,
      'Current legal matter': 5,
      'Disability paperwork': 6,
      'Currently experiencing suicidal thoughts': 7,
      'None of the above': 7
    }.as_json
  end

end
