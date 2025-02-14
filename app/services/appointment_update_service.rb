class AppointmentUpdateService
  
  def initialize(appointment_id, patient)
    @appointment = Appointment.find_by(id: appointment_id)
    @patient = patient
  end

  def update_appointment
    payload = amd_appointment_object.update_params
    response = client.appointments.cancel_appointment(payload)
    result = {}
    result["updated"] = (response["status"] == 10)
    unless response["status"] == 10
      result["error"] = response["title"] if response["title"].present?
      result["errorcode"] = response["errorcode"] if response["errorcode"].present?
    end
    result
  end

  def amd_appointment_object
    Amd::Data::AmdAppointment.new(@appointment)
  end

  def client
    @client ||= Amd::AmdClient.new(office_code: @patient.office_code)
  end
end
