class AddAmdAppointmentIdToPatientAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :patient_appointments, :amd_appointment_id, :integer
  end
end
