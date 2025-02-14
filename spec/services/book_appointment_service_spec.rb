require "rails_helper"

RSpec.describe BookAppointmentService, type: :class do
  let!(:postal_code) { create(:postal_code, zip_code: "30301") }
  let(:patient) do
    skip_patient_amd_creation
    create(:patient, first_name: "test", amd_patient_id: 5983942)
  end
  let!(:insurance_coverage) { create(:insurance_coverage, patient: patient) }
  let!(:responsible_party) { create(:responsible_party) }
  let!(:insurance_coverage) do
    create(:insurance_coverage, patient: patient, policy_holder: responsible_party, relation_to_policy_holder: "self")
  end
  let!(:patient_insurance) { patient.insurance_coverages.last }
  let!(:clinician) { create(:clinician) }
  let!(:address) do
    create(:clinician_address,
      :with_clinician_availability,
      clinician: clinician,
      provider_id: clinician.provider_id,
      postal_code: postal_code.zip_code,
      state: "AK")
  end
  let!(:care) { create(:type_of_care, facility_id: address.facility_id, clinician: clinician) }
  let!(:clinician_availability) { address.clinician_availabilities.first }
  let!(:booked_by) { "patient" }
  let!(:book_appointment_service) { BookAppointmentService.new(clinician_availability, patient, booked_by) }

  describe ".create_appointment!" do

    context "when booking rules are not passed" do
      let!(:booking_rules) { [double("AdvancedNoticeRule", passes_for?: false)] }

      it "returns false" do
        allow(book_appointment_service).to receive(:booking_rules).and_return(booking_rules)

        expect(book_appointment_service.create_appointment!).to be false
      end
    end

    context "when booking rules are passed" do
      let!(:booking_rules) { [double("AdvancedNoticeRule", passes_for?: true)] }
      let!(:amd_scheduler) { instance_double("AmdAppointmentSchedulerService") }

      it "schedules an appointment with AMD" do
        allow(book_appointment_service).to receive(:booking_rules).and_return(booking_rules)  
        allow(book_appointment_service).to receive(:amd_scheduler).and_return(amd_scheduler)

        expect(amd_scheduler).to receive(:schedule_appointment)

        book_appointment_service.create_appointment!
      end
    end

  end

  describe ".post_policy_holder" do
    context "when there is no patient insurance" do
      let!(:patient_insurance) { nil }
      it "does not post the policy holder to AMD" do
        expect(book_appointment_service.post_policy_holder).to be nil
      end
    end
  end
end
