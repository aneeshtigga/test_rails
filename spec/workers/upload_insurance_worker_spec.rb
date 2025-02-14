require "rails_helper"
RSpec.describe UploadInsuranceWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(UploadInsuranceWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a UploadInsuranceWorker" do
    context 'Happy path' do
      it "enqueues an UploadInsuranceWorker job" do
        UploadInsuranceWorker.perform_async

        expect(UploadInsuranceWorker.jobs.size).to eq(1)
      end

      # TODO: implement happy path audit job spec
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

          expect { UploadInsuranceWorker.perform_async(1) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "UploadInsuranceWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
