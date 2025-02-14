class AddBookedByToPatientAppointment < ActiveRecord::Migration[6.1]
  def change
    add_column :patient_appointments, :booked_by, :string, default: "patient"
  end
end
