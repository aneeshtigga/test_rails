class Api::V1::CancellationsController < ApplicationController
  def create
    cancellation = Cancellation.create!(cancellation_params)

    if cancellation.id?
      # this is to delete from clinician_availability_statuses table, so that appointment shows up in Clinician Search Results
      # if we have some data issue and we are deleting a patient_appointment_id that does not exist, validation fails with error "Validation failed: Patient appointment must exist".
      clinician_availability_key = PatientAppointment.find_by(id: cancellation_params[:patient_appointment_id])&.appointment&.clinician_availability_key
      ClinicianAvailabilityStatus.where("clinician_availability_key = ?", clinician_availability_key).destroy_all

      render json: { cancellation_id: cancellation.id }, status: :ok and return
    end

  rescue StandardError => e
    render json: { error: true, message: e.message } and return
  end

  private 

  def cancellation_params
    params.permit(:cancellation_reason_id, :patient_appointment_id, :cancelled_by)
  end
end