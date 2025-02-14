class IntakeAddress < ApplicationRecord
  belongs_to :intake_addressable, polymorphic: true
  validates :state, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :address_line1, presence: true

  def update_patient_address
    patient_detail = patient.client.patients.update_patient(patient_params)
    amd_patient_id = patient_detail["@id"]&.gsub(/\D/, "")

    raise "Error occured in saving patient address" if amd_patient_id.nil?
  end

  def full_address
    loc = self.address_line1.present?? "#{self.address_line1}," : ""
    loc += "#{self.address_line2}," if self.address_line2.present?
    loc += "#{self.city}," if self.city.present?
    loc += "#{self.state}," if self.state.present?
    loc += "#{self.postal_code}" if self.postal_code.present?
    loc
  end

  private

  def patient_params
  #amd accepts apt/suite info as the address2 param
  #and accepts street infor as the address1 param

    {
      '@id': patient.amd_patient_id,
      address:{
        '@address1': self.address_line1,
        '@address2': self.address_line2,
        '@city': self.city,
        '@zip': self.postal_code,
        '@state': self.state
      }
    }
  end

  def check_patient?
    self.intake_addressable_type == "Patient"
  end

  def patient
    self.intake_addressable
  end
end
