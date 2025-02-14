require "rails_helper"

RSpec.describe "Book Appointments", type: :request do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:skip_intake_address_amd) { skip_intake_address_amd_creation }
  let!(:support_number) { create(:support_directory) }
  before do
    allow_any_instance_of(Patient).to receive(:amd_patient).and_return(nil)
  end
  before :all do
    @token = JsonWebToken.encode({ application_name: Rails.application.credentials.ols_api_app_name })
  end

  describe "POST /api/v1/book_appointments" do
    let(:license_key) { "995456" }
    let!(:patient) { create(:patient) }
    let!(:parent_patient) { create(:patient, first_name:"Staged", account_holder_relationship:"self", account_holder: patient.account_holder)}
    let(:clinician) { create(:clinician, license_key: license_key) }
    let(:postal_code) { create(:postal_code) }
    let!(:clinician_address) { create(:clinician_address, clinician: clinician, postal_code: postal_code.zip_code, state: postal_code.state) }
    let!(:support_directory) { create(:support_directory,license_key: license_key, state: postal_code.state)}
    let(:clinician_availability) do
      create(:clinician_availability,
        provider_id: clinician.provider_id,
        facility_id: clinician_address.facility_id,
        license_key: license_key,
        type_of_care: "Adult Therapy")
      end
      
      context "appointment is available" do
        let(:scheduler) { double("AmdAppointmentSchedulerService") }
        let(:amd_appointment_id) { 12_345 }
        
        before do
          allow(scheduler).to receive(:schedule_appointment).and_return(amd_appointment_id)
          allow(AmdAppointmentSchedulerService).to receive(:new).and_return(scheduler)
          allow_any_instance_of(BookAppointmentService).to receive(:episode_id).and_return(5_949_591)
        end
        
        it "responds with patient appointment details" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key
        }

        VCR.use_cassette("amd/create_appointment_with_patient_booking") do 
          token_encoded_post("/api/v1/book_appointments", params: params, token: @token)
        end

        patient_appointment = patient.reload.patient_appointments.last
        expect(json_response["patient_appointment"]).to include(
          "id" => patient_appointment.id,
          "duration" => patient_appointment.duration,
          "modality" => patient_appointment.appointment.modality
        )
      end

      it "responds includes appointment_type" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key
        }

        VCR.use_cassette("amd/create_appointment_with_patient_booking") do
          token_encoded_post("/api/v1/book_appointments", params: params, token: @token)
        end
        patient_appointment = patient.reload.patient_appointments.last
        expect(json_response["patient_appointment"]).to include(
          "type_of_care" => patient_appointment.type_of_care,
        )
      end


      it "takes patient as default booking user when booked_by params is not passed" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key
        }

        token_encoded_post("/api/v1/book_appointments", params: params, token: @token)

        patient_appointment = patient.reload.patient_appointments.last

        expect(json_response["patient_appointment"]["booked_by"]).to eq("patient")
      end

      it "takes admin as booking user when requested with admin value under booked_by param" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key,
          booked_by: "admin"
        }

        token_encoded_post("/api/v1/book_appointments", params: params, token: @token)

        patient_appointment = patient.reload.patient_appointments.last

        expect(json_response["patient_appointment"]["booked_by"]).to eq("admin")
      end
    end

    context "appointment is no longer available" do
      let(:scheduler) { double("AmdAppointmentSchedulerService") }
      let(:amd_appointment_id) { nil }

      before do
        allow(scheduler).to receive(:schedule_appointment).and_return(amd_appointment_id)
        allow(AmdAppointmentSchedulerService).to receive(:new).and_return(scheduler)
        allow_any_instance_of(BookAppointmentService).to receive(:episode_id).and_return(5_949_591)
      end

      it "responds with appointment no longer available message" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key
        }

        token_encoded_post("/api/v1/book_appointments", params: params, token: @token)

        expect(json_response["message"]).to eq("Appointment no longer available")
      end
    end

    context "appointment is not invalid" do
      it "responds with appointment no longer available message" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: 100
        }

        token_encoded_post("/api/v1/book_appointments", params: params, token: @token)

        expect(json_response["message"]).to eq("Appointment no longer available")
      end
    end

    context "appointment raise error" do
      let(:scheduler) { double("AmdAppointmentSchedulerService") }
      let(:amd_appointment_id) { 12_345 }

      it "responds with error message" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key
        }

        token_encoded_post("/api/v1/book_appointments", params: params, token: @token)
        expect(json_response["message"]).to eq("Error occured booking appointment")
      end
    end
  end

  describe "POST /api/v1/book_appointments with different modality scenarios" do
    let(:license_key) { "995456" }
    let!(:account_holder) { create(:account_holder, selected_slot_info: {"reservation": {"modality": "IN-OFFICE"} , "preferences": {"marketingReferralPhone": "123"}}) }
    let!(:account_holder) { create(:account_holder) }
    let!(:patient) { create(:patient, account_holder_id: account_holder.id) }
    let!(:parent_patient) { create(:patient, first_name: "Staged", account_holder_relationship: "self", account_holder: account_holder) }
    let(:clinician) { create(:clinician, license_key: license_key) }
    let(:postal_code) { create(:postal_code) }
    let!(:clinician_address) { create(:clinician_address, clinician: clinician, postal_code: postal_code.zip_code, state: postal_code.state) }
    let!(:support_directory) { create(:support_directory, license_key: license_key, state: postal_code.state) }


    context "virtual_or_video_visit=true and in_person_visit=true" do
      let(:type_of_care) { create(:type_of_care, in_person_visit: true, virtual_or_video_visit: true) }
      let(:clinician_availability) do
        create(:clinician_availability,
               provider_id: clinician.provider_id,
               facility_id: clinician_address.facility_id,
               license_key: license_key,
               type_of_care: type_of_care.type_of_care,
               virtual_or_video_visit: true,
               in_person_visit: true)
      end
      let(:scheduler) { double("AmdAppointmentSchedulerService") }
      let(:amd_appointment_id) { 12_345 }

      before do
        allow(scheduler).to receive(:schedule_appointment).and_return(amd_appointment_id)
        allow(AmdAppointmentSchedulerService).to receive(:new).and_return(scheduler)
        allow_any_instance_of(BookAppointmentService).to receive(:episode_id).and_return(5_949_591)
      end

      it "modality selected is video and returns video_visit" do
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key
        }

        VCR.use_cassette("amd/create_appointment_with_patient_booking") do
          token_encoded_post("/api/v1/book_appointments", params: params, token: @token)
        end
        patient_appointment = patient.reload.patient_appointments.last
        expect(json_response["patient_appointment"]).to include(
                                                          "id" => patient_appointment.id,
                                                          "duration" => patient_appointment.duration,
                                                          "modality" => "video_visit"
                                                        )
      end

      it "modality selected is in office and returns in_office" do
        account_holder.update(selected_slot_info: { 'reservation': { 'modality': "IN-OFFICE" } , 'preferences': {'marketingReferralPhone': '123'} })
        params = {
          patient_id: patient.id,
          clinician_availability_key: clinician_availability.clinician_availability_key
        }

        VCR.use_cassette("amd/create_appointment_with_patient_booking") do
          token_encoded_post("/api/v1/book_appointments", params: params, token: @token)
        end

        patient_appointment = patient.reload.patient_appointments.last
        expect(json_response["patient_appointment"]).to include(
          "id" => patient_appointment.id,
          "duration" => patient_appointment.duration,
          "modality" => "in_office"
        )
      end
    end
  end
end
