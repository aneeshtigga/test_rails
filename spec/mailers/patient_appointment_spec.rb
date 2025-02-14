require "rails_helper"

RSpec.describe PatientAppointmentMailer, type: :mailer do
  let!(:skip_patient_amd) { skip_patient_amd_creation }
  let!(:clinician_address) { create(:clinician_address) }
  let!(:account_holder) { create(:account_holder) }
  let!(:state) { create(:state, name: "FL", full_name: "Florida") } # This is how is stored in QA and PROD (FL, AZ, etc...)
  let!(:patient) do
    VCR.use_cassette("amd/push_referral") do
      create(:patient, account_holder: account_holder, account_holder_relationship: :self, amd_patient_id: 5_983_942)
    end
  end
  let!(:clinician) { create(:clinician, telehealth_url: "https://telehealthurl.com") }

  let!(:clinician_without_telehealth_url) { create(:clinician, telehealth_url: "") }
  # Special conditions regarding Massachussetts clinicians, 2 license keys
  let!(:clinician_massachussetts) { create(:clinician, license_key: 139414) }
  let!(:clinician2_massachussetts) { create(:clinician, license_key: 147611) }

  let!(:clinician_address) { create(:clinician_address, state: "FL", clinician: clinician) }
  let!(:appointment) { create(:appointment, clinician: clinician, clinician_address: clinician_address )}
  let!(:appointment_ma) { create(:appointment, clinician: clinician_massachussetts, clinician_address: clinician_address, modality: 1 )}
  let!(:appointment2_ma) { create(:appointment, clinician: clinician2_massachussetts, clinician_address: clinician_address, modality: 1 )}
  let!(:patient_appointment) do
    create(:patient_appointment,
      clinician: clinician,
      clinician_address: clinician_address,
      patient: patient,
      appointment: appointment
    )

  end 
  let!(:patient_appointment_without_telehealth_url) do
    create(:patient_appointment,
      clinician: clinician_without_telehealth_url,
      clinician_address: clinician_address,
      patient: patient,
      appointment: appointment
    )
  end 
  let!(:support_info) { create(:support_directory, location: "Florida", state: 'FL') }

  let!(:mail) { PatientAppointmentMailer.with(patient_appointment: patient_appointment).appointment_confirmation }
  let!(:mail_without_telehealth_url) { PatientAppointmentMailer.with(patient_appointment: patient_appointment_without_telehealth_url).appointment_confirmation }

  # MA patient appointments
  let!(:patient_appointment_ma) do
    create(:patient_appointment,
           clinician: clinician_massachussetts,
           clinician_address: clinician_address,
           patient: patient,
           appointment: appointment_ma
          )
  end
  let!(:patient_appointment2_ma) do
    create(:patient_appointment,
           clinician: clinician2_massachussetts,
           clinician_address: clinician_address,
           patient: patient,
           appointment: appointment2_ma
          )
  end
  let!(:support_info) { create(:support_directory, location: "Florida", state: 'FL') }
  let!(:mail_ma) { PatientAppointmentMailer.with(patient_appointment: patient_appointment_ma).appointment_confirmation }
  let!(:mail2_ma) { PatientAppointmentMailer.with(patient_appointment: patient_appointment2_ma).appointment_confirmation }

  it "renders the headers" do
    expect(mail.subject).to eq("LifeStance Appointment Confirmation")
    expect(mail.to).to include(account_holder.confirmation_email)
    expect(mail.from).to eq(["noreply@lifestance.com"])
  end

  it "renders the body" do
    expect(mail.body.encoded).to match("#{patient.display_name}, your appointment is booked.")
    expect(mail.body.encoded).to match("#{patient_appointment.type_of_care}")
    expect(mail.html_part.decoded).to match("#{Rails.application.credentials.host_url}/find-care/booking/provider/#{clinician.first_name.downcase}-#{clinician.last_name.downcase}-#{clinician.id}")
  end

  context "patient relationship to account holder is a child" do
    it "renders the title" do
      patient.update(account_holder_relationship: :child)

      expect(mail.body.encoded).to match("#{patient.display_name}&#39;s appointment is booked.")
    end
  end

  context "appointment is by video" do
    it "renders the correct appointment modality message" do
      appointment.video_visit!

      expect(mail.body.encoded).to match("Use this link to access your virtual")
      expect(mail.body.encoded).to match("Join waiting room")
      expect(mail.body.encoded).to match("https://telehealthurl.com")
    end
  end

  context "Cancel appointment" do
    it "renders a control to Cancel appointment" do
      expect(mail.body.encoded).to match("Cancel Appointment")
    end
  end

  context "Missing telehealth link" do
    it "renders the missing telehealth-url-error" do
      appointment.video_visit!

      expect(mail_without_telehealth_url.body.encoded).to match("telehealth-url-error")
    end
  end

  context "Support number" do
    it "renders dynamic support contact" do 
      expect(mail.body.encoded).to include(support_info.intake_call_in_number)
    end
  end

  context "Telelehealth visit" do
    it "Has the video visit text and with link" do
      appointment.video_visit!
      expect(mail.body.encoded).to include("Join waiting room")
    end
  end

  context "Massachussetts - license key 139414 and TH" do
    it "Has the video visit text updated and with no link" do
      telehealth_text = "You will receive a link to join your"
      expect(mail_ma.body.encoded).to include(telehealth_text)
      expect(mail_ma.body.encoded).not_to include("Join waiting room")
    end
  end

  context "Massachussetts - license key 147611 and TH" do
    it "Has the video visit text updated and with no link" do
      telehealth_text = "You will receive a link to join your"
      expect(mail2_ma.body.encoded).to include(telehealth_text)
      expect(mail2_ma.body.encoded).not_to include("Join waiting room")
    end
  end
end
