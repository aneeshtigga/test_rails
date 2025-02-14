require "rails_helper"

RSpec.describe PatientAppointment, type: :model do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:patient) { create(:patient) }
  let!(:clinician) { create(:clinician) }
  let!(:clinician_address) { create(:clinician_address, clinician: clinician) }
  let!(:postal_code) { create(:postal_code, zip_code: clinician_address.postal_code) }
  let!(:appointment) { create(:appointment, clinician: clinician, clinician_address: clinician_address) }
  let!(:appointment) { create(:appointment, clinician: clinician, clinician_address: clinician_address) }
  let!(:patient_appointment) do
    create(
      :patient_appointment,
      clinician: clinician,
      clinician_address: clinician_address,
      patient: patient,
      appointment: appointment
    )
  end

  describe "associations" do
    it { should belong_to(:appointment) }
    it { should belong_to(:patient) }
    it { should belong_to(:clinician) }
    it { should belong_to(:clinician_address) }
  end

  describe "status enum" do
    it do
      should define_enum_for(:status).with_values(%i[booked cancelled])
    end
  end

  describe "#icalendar" do
    it "returns an instance of icalendar" do
      expect(patient_appointment.icalendar).to be_an_instance_of(Icalendar::Calendar)
    end
  end

  describe "#clinician_timezone" do
    it "returns the local timezone of the clinician" do
      clinician_timezone = PostalCode.find_by(zip_code: clinician_address.postal_code).time_zone

      expect(patient_appointment.clinician_timezone).to eq(clinician_timezone)
    end
  end
end
