# Used to update AMD custom data tab called "Pt Contact"
class PatientCustomDataPtContactService < PatientCustomData

  def post_data
    super if patient.emergency_contact
  end
  
  # tab name is "Pt Contact" but code is "#PC". Yes. With a hash. Really.
  def tab_code
    "#PC"
  end

  def update_data
    super if patient&.emergency_contact&.amd_instance_id.present?
  end

  def fieldvalue_by_name(name)
    emergency_contact = patient&.emergency_contact

    case name
    when "Contact"
      emergency_contact.full_name
    when "Relationship"
      emergency_contact.relationship_to_patient_text
    when "Phone"
      emergency_contact.phone
    end
  end
end
