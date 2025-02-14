require "rails_helper"
RSpec.describe PatientAppointmentHoldMailerWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(PatientAppointmentHoldMailerWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a PatientAppointmentHoldMailerWorker" do
    context 'Happy path' do
      let!(:skip_patient_amd) { skip_patient_amd_creation }
      let!(:clinician) { create(:clinician) }
      let!(:address) { create(:clinician_address, clinician: clinician) }
      let!(:patient) do
        VCR.use_cassette("amd/push_referral") do
          create(:patient, amd_patient_id: 5_983_942)
        end
      end
      let!(:toc) { create(:type_of_care, clinician: clinician) }
      let!(:appointment) { create(:appointment, clinician: clinician, clinician_address: address) }
      let!(:patient_appointment) { create(:patient_appointment, patient: patient, appointment: appointment, clinician: clinician, clinician_address: address) }
      let!(:audit_job_count) { AuditJob.count }
      
      it "enqueues an PatientAppointmentHoldMailerWorker job" do

        PatientAppointmentHoldMailerWorker.perform_async(patient_appointment.id)

        expect(PatientAppointmentHoldMailerWorker.jobs.size).to eq(1)
      end

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          PatientAppointmentHoldMailerWorker.perform_async(patient_appointment.id)
          expect(AuditJob.last.job_name).to eq "PatientAppointmentHoldMailerWorker"
          expect(AuditJob.last.status).to eq "completed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end

    context 'Sad path' do
      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { PatientAppointmentHoldMailerWorker.perform_async(1) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "PatientAppointmentHoldMailerWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
