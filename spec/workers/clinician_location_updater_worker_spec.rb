require "rails_helper"
RSpec.describe ClinicianLocationUpdaterWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ClinicianLocationUpdaterWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianLocationUpdaterWorker" do
    context 'Happy path' do
      let!(:audit_job_count) { AuditJob.count }

      it "enqueues an ClinicianLocationUpdaterWorker job" do
        ClinicianLocationUpdaterWorker.perform_async

        expect(ClinicianLocationUpdaterWorker.jobs.size).to eq(1)
        expect(ClinicianLocationUpdaterWorker).to have_enqueued_sidekiq_job
      end

      it "imports data from the clinician mart" do
        Sidekiq::Testing.inline! do
          expect(ClinicianLocationSync).to receive(:sync_data).with(1, 2, 3, 4)

          ClinicianLocationUpdaterWorker.perform_async(1, 2, 3, 4)
          expect(AuditJob.count).to eq(audit_job_count + 1)
          expect(AuditJob.last.job_name).to eq "ClinicianLocationUpdaterWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end
    end

    context 'Sad path' do
      before do
        allow(ClinicianLocationSync).to receive(:sync_data).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { ClinicianLocationUpdaterWorker.perform_async(1, 2, 3, 4) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "ClinicianLocationUpdaterWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
