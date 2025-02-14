require "rails_helper"

RSpec.describe PatientHoldAppointmentMailer, type: :mailer do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:clinician_address) { create(:clinician_address) }
  let!(:account_holder) { create(:account_holder) }
  let!(:patient) do
    VCR.use_cassette("amd/push_referral") do
      create(:patient, account_holder: account_holder, account_holder_relationship: :self, amd_patient_id: 5_983_942)
    end
  end
  let!(:clinician) { create(:clinician) }
  let!(:clinician_address) { create(:clinician_address, clinician: clinician) }
  let!(:appointment) { create(:appointment, clinician: clinician, clinician_address: clinician_address) }
  let!(:patient_appointment) do
    create(:patient_appointment,
           clinician: clinician,
           clinician_address: clinician_address,
           patient: patient,
           appointment: appointment)
  end

  let!(:mail) { PatientHoldAppointmentMailer.with(patient_appointment: patient_appointment).hold_appointment }

  it "renders the headers" do
    expect(mail.to).to include(account_holder.email)
    expect(mail.from).to eq(["noreply@lifestance.com"])
  end

  it "renders the body" do
    expect(mail.body.encoded).to match("#{patient.display_name}, your visit is booked")
    expect(mail.body.encoded).to match("Cancel Appointment")
    expect(mail.body.encoded).to match("Please cancel at least 2 business days")
  end
end
