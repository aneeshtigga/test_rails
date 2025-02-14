class SignaturePdfCreator
  def initialize(signature, patient_id, filename = "signature.pdf")
    @signature = signature
    @filename = filename
    @date_signed = Time.now.strftime("%m/%d/%Y")
    @path = Rails.root.join("tmp", filename)
    @patient = Patient.find_by(id: patient_id)
  end

  def generate_signature_pdf
    content =  if patient.account_holder_relationship == "self"
                 get_self_content
               else
                 get_child_content
               end
    WickedPdf.new.pdf_from_string(content)
  end

  def get_self_content
    "<table> #{patient_info} #{signature_info} </table>"
  end

  def get_child_content
    "<table> #{patient_info} #{account_holder_info} #{signature_info} </table>"
  end

  def patient_info
    "<tr>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: bold; font-size: 16px; line-height: 24px; color: #000000;'>Name:</span>
      </td>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: normal; font-size: 16px; line-height: 24px; color: #000000;'>#{patient_full_name}</span>
      </td>
    </tr>
    <tr>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: bold; font-size: 16px; line-height: 24px; color: #000000;'>Date of birth:</span>
      </td>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: normal; font-size: 16px; line-height: 24px; color: #000000;'>#{patient_dob}</span>
      </td>
    </tr>"
  end

  def account_holder_info
    "<tr>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: bold; font-size: 16px; line-height: 24px; color: #000000;'>Parent/Guardian:</span>
      </td>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: normal; font-size: 16px; line-height: 24px; color: #000000;'>#{account_holder_name}</span>
      </td>
    </tr>
    <tr>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: bold; font-size: 16px; line-height: 24px; color: #000000;'>Relationship to child:</span>
      </td>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: normal; font-size: 16px; line-height: 24px; color: #000000;'>#{relationship_to_child}</span
      </td>
    </tr>"
  end

  def signature_info
    "<tr>
      <td style ='white-space: nowrap;' >
        <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: bold; font-size: 16px; line-height: 24px; color: #000000;'>Electronically signed by:</span>
      </td>
      <td style ='white-space: nowrap;'>
       <span style='padding: 8px; font-family: Helvetica; font-style: normal; font-weight: normal; font-size: 16px; line-height: 24px; color: #000000;'>#{e_sign}</span>
      </td>
    </tr>"
  end

  def patient_full_name
    "#{@patient.first_name.capitalize} #{@patient.last_name.capitalize}"
  end

  def patient_dob
    @patient.date_of_birth.to_date.strftime("%m/%d/%Y")
  end

  def e_sign
    "#{signature}, #{date_signed}"
  end

  def account_holder_name
    parent = @patient.account_holder
    
    "#{parent.first_name.capitalize} #{parent.last_name.capitalize}"
  end

  def relationship_to_child
    return "Parent" if @patient.account_holder_relationship == "child"

    @patient.account_holder_relationship
  end

  private

  attr_reader :signature, :date_signed, :filename, :path, :patient
end

