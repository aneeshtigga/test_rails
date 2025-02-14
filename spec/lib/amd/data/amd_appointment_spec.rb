require "rails_helper"

RSpec.describe Amd::Data::AmdAppointment, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:clinician) { create(:clinician) }
  let!(:address) { create(:clinician_address, clinician: clinician) }
  let!(:patient) do
    VCR.use_cassette("amd/push_referral") do
       create(:patient, amd_patient_id: 5_983_942, marketing_referral_id: 464)
     end
  end 
  let!(:toc) { create(:type_of_care, clinician: clinician) }

  let!(:appointment) { create(:appointment, clinician: clinician, clinician_address: address) }
  let!(:patient_appointment) { create(:patient_appointment, patient: patient, appointment: appointment, clinician: clinician, clinician_address: address) }
  let!(:clinician_availability) {create(:clinician_availability, provider_id: appointment.clinician.provider_id, profile_id: 3, column_id: 17, facility_id: appointment.clinician_address.facility_id ) }

  describe "#initialize" do
    it "instance is created" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt).to be_an_instance_of(Amd::Data::AmdAppointment)
    end
  end

  describe "#appointment" do
    it "returns an instance of Appointment" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.appointment).to be_an_instance_of(Appointment)
    end

    it "returns an appointment object" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.appointment).to eq(appointment)
    end
  end

  describe "#patientid" do
    it "returns the patients amd_patient_id value" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.patientid).to eq(5983942)
    end
  end

  describe "#startdatetime" do
    it "returns the appointment start_time value" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.startdatetime).to eq(appointment.start_time.in_time_zone("America/New_York").strftime('%Y-%m-%dT%H:%M:%S.%L'))
    end
  end

  describe "#duration" do
    it "returns the appointment end_time - start_time value in minutes" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.duration).to eq(30)
    end
  end

  describe "#profileid" do
    it "returns the clinician availability profile_id value" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.profileid).to eq(3)
    end
  end

  describe "#columnid" do
    it "returns the clinician availability column_id value" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.columnid).to eq(17)
    end
  end

  describe "#type" do
    it "returns an array of hashed" do
      appt = Amd::Data::AmdAppointment.new(appointment)
      toc = clinician.type_of_cares.first

      expect(appt.type).to eq([{ "id" => toc.amd_appt_type_uid, "name" => toc.amd_appointment_type }])
    end
  end

  describe "#episodeid" do
    it "returns the episode id" do
      VCR.use_cassette('amd/get_episode_id') do
        appt = Amd::Data::AmdAppointment.new(appointment)

        expect(appt.episodeid).to_not be_nil
        expect(appt.episodeid).to eq(5948273)
      end
    end
  end

  describe "#amd_appointment_id" do
    it "returns amd_appointment_id" do
      appt = Amd::Data::AmdAppointment.new(appointment)

      expect(appt.amd_appointment_id).to eq(9543341)
    end
  end

  describe "#comments" do
    it "returns patient's appointment note" do
      appt = Amd::Data::AmdAppointment.new(appointment)

      expect(appt.comments).to eq(patient_appointment.appointment_note)
    end
  end

  describe "#params" do
    it "returns a hash with needed params to create an amd appointment" do
      params = {
        "patientid" => patient.amd_patient_id,
        "columnid" => 17,
        "startdatetime" => appointment.start_time.in_time_zone("America/New_York").strftime('%Y-%m-%dT%H:%M:%S.%L'),
        "duration" => 30,
        "profileid" => 3,
        "episodeid" => 5948273,
        "type" => [{ "id" => clinician.type_of_cares.first.amd_appt_type_uid, "name" => clinician.type_of_cares.first.amd_appointment_type }],
        "comments" => patient_appointment.appointment_note
      }

      VCR.use_cassette('amd/get_episode_id') do
        appt = Amd::Data::AmdAppointment.new(appointment)
        expect(appt.params).to eq(params)
      end
    end
  end

  describe "#update_params" do
    it "returns a hash for update appointment" do
      update_params = {
        "id" => appointment.patient_appointment.amd_appointment_id,
        "columnid" => 17,
        "startdatetime" => appointment.start_time.in_time_zone("America/New_York").strftime('%Y-%m-%dT%H:%M:%S.%L')
      }

      appt = Amd::Data::AmdAppointment.new(appointment)
      expect(appt.update_params).to eq(update_params)
    end
  end

  describe "#cancel_params" do
    it "returns a hash for cancel appointment" do
      cancel_params = {
        "id" => appointment.patient_appointment.amd_appointment_id
      }

      appt = Amd::Data::AmdAppointment.new(appointment)

      expect(appt.cancel_params).to eq(cancel_params)
    end
  end
end