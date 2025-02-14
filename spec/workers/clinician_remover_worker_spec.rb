require "rails_helper"
RSpec.describe ClinicianRemoverWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ClinicianRemoverWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianRemoverWorker" do
    context 'Happy path' do
      let!(:audit_job_count) { AuditJob.count }
      let!(:provider) { create(:clinician) }
      let!(:provider2) { create(:clinician) }

      it "enqueues an ClinicianRemoverWorker job" do
        ClinicianRemoverWorker.perform_async

        expect(ClinicianRemoverWorker.jobs.size).to eq(1)
        expect(ClinicianRemoverWorker).to have_enqueued_sidekiq_job
      end

      it "imports data from the clinician mart" do
        Sidekiq::Testing.inline! do
          ClinicianRemoverWorker.perform_async(provider2.id)

          expect(AuditJob.count).to eq(audit_job_count + 1)
          expect(AuditJob.last.job_name).to eq "ClinicianRemoverWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end
    end

    context 'Sad path' do
      before do
        allow(Clinician).to receive(:find_by).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { ClinicianRemoverWorker.perform_async(999) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "ClinicianRemoverWorker"
          expect(AuditJob.last.status).to eq "failed"
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
