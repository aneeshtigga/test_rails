require "rails_helper"

RSpec.describe Appointment, type: :model do
  describe "associations" do
    it { should belong_to(:clinician) }
    it { should belong_to(:clinician_address) }
  end

  describe "validations" do
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
  end

  describe "modality enum" do
    it do
      should define_enum_for(:modality)
        .with_values(%i[in_office video_visit both])
    end
  end

  describe "callbacks" do
    context "update_patient_office_code" do
      let!(:skip_patient_amd) { skip_patient_amd_creation }
      let(:patient) { create(:patient) }
      let(:new_clinician_address) { create(:clinician_address, office_key: 1111) }
      let(:patient_appointment) { create(:patient_appointment, patient: patient)}
      let(:appointment) { patient_appointment.appointment }

      it "update patient office code if patient appointment is updated" do
        appointment.update(clinician_address: new_clinician_address)
        expect(appointment.reload.patient.office_code).to eq(new_clinician_address.office_key)
      end
    end
  end

  describe "amd_object method" do
    it "initializes amd appointment class"do
      appointment = create(:appointment)
      expect(appointment.amd_object.appointment).to eq(appointment)
    end
  end

  describe 'add column' do
    it 'should have a new column clinician_availability_key' do
      appointment = create(:appointment)
      expect(appointment.clinician_availability_key).not_to be nil
    end

  end
end
