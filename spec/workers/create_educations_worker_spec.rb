require "rails_helper"
RSpec.describe CreateEducationsWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(CreateEducationsWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a CreateEducationsWorker" do
    context 'Happy path' do
      let!(:audit_job_count) { AuditJob.count }

      it "enqueues an CreateEducationsWorker job" do
        education = create(:clinician_education)
        CreateEducationsWorker.perform_async([education.npi])

        expect(CreateEducationsWorker.jobs.size).to eq(1)
        expect(CreateEducationsWorker).to have_enqueued_sidekiq_job([education.npi])
      end

      it "receive create_data from the clinician_education_sync" do
        education = create(:clinician_education)
        Sidekiq::Testing.inline! do
          expect(ClinicianEducationSync).to receive(:create_data).with([education.npi])

          CreateEducationsWorker.perform_async([education.npi])
        end
      end

      it "creates education from clinician_education" do
        clinician = create(:clinician)
        education = create(:clinician_education, npi: clinician.npi)
        Sidekiq::Testing.inline! do
          CreateEducationsWorker.perform_async([education.npi])
          expect(Education.count).to eq 1
          expect(AuditJob.last.job_name).to eq "CreateEducationsWorker"
          expect(AuditJob.last.status).to eq "completed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end

    context 'sad path' do
      before do
        allow(ClinicianEducationSync).to receive(:create_data).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { CreateEducationsWorker.perform_async(1) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "CreateEducationsWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
