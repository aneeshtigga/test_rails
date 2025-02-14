require "rails_helper"
RSpec.describe InsuranceWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(InsuranceWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a InsuranceWorker" do
    context 'happy path' do
      let!(:audit_job_count) { AuditJob.count }
      let(:patient) { create(:patient) }
      
      it "enqueues an InsuranceWorker job" do
        allow_any_instance_of(Patient).to receive(:existing_amd_patient).and_return(false)

        Sidekiq::Testing.inline! do
          InsuranceWorker.perform_async(patient.id)

          expect(AuditJob.count).to eq(audit_job_count + 1)
          expect(AuditJob.last.job_name).to eq "InsuranceWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end
    end

    context 'sad path' do
      let!(:audit_job_count) { AuditJob.count }
      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { InsuranceWorker.perform_async(1) }.to raise_error(NoMethodError)
          expect(AuditJob.last.job_name).to eq "InsuranceWorker"
          expect(AuditJob.last.status).to eq "failed"

          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
