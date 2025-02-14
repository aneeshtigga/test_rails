require "rails_helper"
RSpec.describe ClinicianSyncWorker, type: :worker do
  describe "Sidekiq Worker" do
    it "responds to #perform" do
      expect(ClinicianSyncWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianSyncWorker" do
    context 'Happy path' do
      let!(:audit_job_count) { AuditJob.count }
      let!(:provider) { create(:clinician) }

      it "enqueues an ClinicianSyncWorker job" do
        ClinicianSyncWorker.perform_async

        expect(ClinicianSyncWorker.jobs.size).to eq(1)
        expect(ClinicianSyncWorker).to have_enqueued_sidekiq_job
      end

      it "imports data from the clinician mart" do
        Sidekiq::Testing.inline! do
          ClinicianSyncWorker.perform_async

          expect(AuditJob.count).to eq(audit_job_count + 1)
          expect(AuditJob.last.job_name).to eq "ClinicianSyncWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end
    end

    context 'Sad path' do
        before do
            allow(ClinicianMart).to receive(:active).and_raise(StandardError)
        end
        let!(:audit_job_count) { AuditJob.count }

        it "ensures the proper AuditJob is created" do
          Sidekiq::Testing.inline! do
            # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
            expect(Bugsnag).to receive(:notify).once

            expect { ClinicianSyncWorker.perform_async }.to raise_error(StandardError)
            expect(AuditJob.last.job_name).to eq "ClinicianSyncWorker"
            expect(AuditJob.last.status).to eq "failed"
            expect(AuditJob.count).to eq(audit_job_count + 1)
          end
        end
    end
  end
end
