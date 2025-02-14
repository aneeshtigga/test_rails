class Appointment < ApplicationRecord
  belongs_to :clinician
  belongs_to :clinician_address
  has_one :patient_appointment, dependent: :destroy
  has_one :patient, through: :patient_appointment

  validates :start_time, :end_time, presence: true

  before_update :update_patient_office_code

  enum modality: { in_office: 0, video_visit: 1, both: 2 }

  def duration
    ((end_time - start_time) / 60).round
  end

  def amd_object
    Amd::Data::AmdAppointment.new(self)
  end

  def update_patient_office_code
    patient.update(office_code: clinician_address.office_key)
  end
end
