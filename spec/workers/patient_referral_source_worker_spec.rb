require 'rails_helper'

describe PatientReferralSourceWorker, type: :worker do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  describe "PatientReferralSourceWorker" do
    it "should respond to #perform" do
      expect(PatientReferralSourceWorker.new).to respond_to(:perform)
    end
  end

  describe "perform" do
    context 'Happy path' do
      let!(:address) { create(:clinician_address) }
      let!(:skip_patient_amd) { skip_patient_amd_creation }
      let!(:patient) { create(:patient, amd_patient_id: 5983957, referral_source: "Search engine (Google, Bing, etc.)") }
      let!(:audit_job_count) { AuditJob.count }

      it "posts the patients referral source on AMD" do
        skip_referral_amd_creation

        expect(patient.marketing_referral_id).to be nil
        Sidekiq::Testing.inline! do
          PatientReferralSourceWorker.perform_async(patient.id)
          patient.reload
        end
        expect(patient.marketing_referral_id).to_not be nil
        expect(AuditJob.last.job_name).to eq "PatientReferralSourceWorker"
        expect(AuditJob.last.status).to eq "completed"
          
        expect(AuditJob.count).to eq(audit_job_count + 1)
      end
    end

    context 'Sad path' do
      before do
        allow(Patient).to receive(:find_by).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { PatientReferralSourceWorker.perform_async(1) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "PatientReferralSourceWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
