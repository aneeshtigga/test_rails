require "rails_helper"
describe AmdAppointmentSchedulerService, type: :class do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end


  let(:selected_slot_info) do
    { selected_slot_info: { reservation: { modality: "IN-OFFICE" } } }
  end

  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:clinician_availability) { create(:clinician_availability, virtual_or_video_visit: 0, in_person_visit: 1) }


  let!(:patient) { create(:patient, amd_patient_id: 5_983_949, marketing_referral_id: 123) }
  let!(:account_holder) { create(:account_holder, selected_slot_info) }
  let!(:clinician) { create(:clinician, provider_id: 1) }
  let!(:type_of_care) { create(:type_of_care, clinician_id: clinician.id, facility_id: 1, virtual_or_video_visit: false, in_person_visit: true) }
  let!(:clinician_address) { create(:clinician_address, clinician: clinician, postal_code: "74073", provider_id: clinician.provider_id, office_key: 995456) }
  let(:appointment_scheduler) { AmdAppointmentSchedulerService.new(patient, clinician_availability, 1, :in_office) }
  before do
    authenticate_amd_api
  end

  describe "Schedule appointment" do
    context "Standard api call" do
      let!(:type_of_care_follow_up) { create(:type_of_care, type_of_care: "F/U Child Neuro/Psych Testing", clinician_id: clinician.id, facility_id: 1, virtual_or_video_visit: false, in_person_visit: true) }

      it "returns the appointment id" do
        skip "VCR is the devil"
        
        VCR.use_cassette("amd_appointment_scheduler_success", record: :new_episodes) do
          result = appointment_scheduler.schedule_appointment
          expect(result["color"]).to match(clinician_availability.in_person_color)
        end
      end


      it "returns the appointment id" do
        skip "VCR is the devil"
        VCR.use_cassette("amd_appointment_scheduler_success", record: :new_episodes) do
          result = appointment_scheduler.schedule_appointment
          expect(result["appointmenttype"][0]["name"]).not_to match(type_of_care_follow_up.type_of_care)
        end
      end
    end
  end
end
