class EmergencyContact < ApplicationRecord
  enum relationship_to_patient: { spouse: 0, child: 1, parents: 2, friend: 3, other: 4 }

  belongs_to :patient

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def relationship_to_patient_text
    case relationship_to_patient
    when "spouse"
      "Spouse/Partner"
    when "child"
      "Adult Child"
    else
      relationship_to_patient.titlecase
    end
  end
end
