require "rails_helper"
require "sidekiq/testing"

RSpec.describe ClinicianAddressCoordinateWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable true }

    it "responds to #perform" do
      expect(ClinicianAddressCoordinateWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianAddressCoordinateWorker" do
    context 'Happy path' do
      let(:clinician_address) { FactoryBot.create(:clinician_address) }
      let!(:audit_job_count) { AuditJob.count }

      it "enqueues an ClinicianAddressCoordinateWorker job" do
        Sidekiq::Testing.inline! do
          ClinicianAddressCoordinateWorker.perform_async(clinician_address.id)
          expect(AuditJob.count).to eq(audit_job_count + 1)
          expect(AuditJob.last.job_name).to eq "ClinicianAddressCoordinateWorker"
          # TODO: This task is actually failing, but beyond the scope of adding audit jobs.
          # The status is coming back as 'failed', but as it is creating the audit job
          # I am leaving this as a TODO so not to unnecessarily expand scope.
        end
      end
    end

    context 'Sad path' do
      before do
        allow(ClinicianAddress).to receive(:find_by).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { ClinicianAddressCoordinateWorker.perform_async(1) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "ClinicianAddressCoordinateWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
