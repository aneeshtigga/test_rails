
# Abstract class used to push data to Custom Tabs in AMD
class PatientCustomData
  attr_accessor :patient

  def initialize(patient_id)
    @patient = Patient.find_by(id: patient_id)
  end

  def post_pronouns_data
    @patient.client.custom_data.save_patients_data(patient_custom_params) unless @patient.amd_pronouns_updated
  end

  def post_data
    @patient.client.custom_data.save_patients_data(patient_custom_params)
  end

  def update_data
    temp_patient_custom_params = patient_custom_params
    temp_patient_custom_params[:instance_id] = @patient&.emergency_contact&.amd_instance_id
    @patient.client.custom_data.update_patients_data(temp_patient_custom_params)
  end

  def lookup_template
    @lookup_template ||= @patient.client.custom_data.lookup_custom_template(tab_code)
  end

  def patient_custom_params
    {
      custom_tab: (lookup_template.map{|e| e[:name]}.include?"Contact") ? "Emergency Contact" : "Pronouns",
      patient_id: @patient.amd_patient_id,
      template_id: lookup_template[0][:template_id],
      field_value_list: field_value_list
    }
  end

  def field_value_list
    lookup_template.map do |field|
      each_field_value_list = {
        '@templatefieldid': field[:id],
        '@value': fieldvalue_by_name(field[:name])
      }

      if @patient&.emergency_contact&.amd_instance_id.present? && ["Contact", "Relationship", "Phone"].include?(field[:name])
        each_field_value_list[:@id] = amd_field_id_by_name(field[:name])
      end

      each_field_value_list
    end
  end

  def tab_code
    raise NotImplementedError
  end

  def fieldvalue_by_name(name)
    raise NotImplementedError
  end

  def amd_field_id_by_name(name)
    emergency_contact = patient.emergency_contact

    case name
    when "Contact"
      emergency_contact.amd_contact_id.to_s
    when "Relationship"
      emergency_contact.amd_relationship_to_patient_id.to_s
    when "Phone"
      emergency_contact.amd_phone_id.to_s
    end
  end
end
