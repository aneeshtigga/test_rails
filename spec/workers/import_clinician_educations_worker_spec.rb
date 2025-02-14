require "rails_helper"
RSpec.describe ImportClinicianEducationsWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ImportClinicianEducationsWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ImportClinicianEducations" do
    let(:clinician) { create(:clinician) }
    context "Happy path" do

      let!(:audit_job_count) { AuditJob.count }
      let(:audit_job) { AuditJob.last }
      
      it "enqueues an ImportClinicianLocations job for imports" do
        create(:clinician_location_mart)

        ImportClinicianEducationsWorker.perform_async
        expect(ImportClinicianEducationsWorker.jobs.size).to eq(1)
        expect(ImportClinicianEducationsWorker).to have_enqueued_sidekiq_job
      end

      it "imports data from the clinician educations" do
        create(:clinician_education, npi: clinician.npi)
        Sidekiq::Testing.inline! do
          ImportClinicianEducationsWorker.perform_async
          expect(Education.count).to eq 1
          
          expect(audit_job.job_name).to eq "ImportClinicianEducationsWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end
    end

    context "Unhappy path" do
      before do
        allow(ClinicianEducationSync).to receive(:import_data).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }
      let(:audit_job) { AuditJob.last }

      it "ensures the proper AuditJob is created" do
        create(:clinician_education, npi: clinician.npi)
        Sidekiq::Testing.inline! do
          # Once for the ImportClincianEducationsWorker and once for the CreateEducationsWorker
          expect(Bugsnag).to receive(:notify)
          expect { ImportClinicianEducationsWorker.perform_async }.to raise_error(StandardError)
          expect(Education.count).to eq 0
          expect(AuditJob.count).to eq (audit_job_count + 1)

          expect(audit_job.job_name).to eq "ImportClinicianEducationsWorker"
          expect(AuditJob.last.status).to eq "failed"
        end
      end
    end
  end
end
