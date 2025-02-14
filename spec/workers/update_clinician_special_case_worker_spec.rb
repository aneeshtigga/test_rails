require "rails_helper"
RSpec.describe UpdateClinicianSpecialCaseWorker, type: :worker do
  let!(:license_type_1) { create(:license_type, name: "MD") }
  let!(:license_type_2) { create(:license_type, name: "MS") }
  let!(:expertise_1) { create(:expertise, name: "Depression") }
  let!(:expertise_2) { create(:expertise, name: "Eating Disorder") }
  let!(:language_1) { create(:language, name: "English") }
  let!(:language_2) { create(:language, name: "Spanish") }
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(UpdateClinicianSpecialCaseWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a UpdateClinicianSpecialCaseWorker" do
    context 'Happy path' do
      let!(:audit_job_count) { AuditJob.count }

      it "enqueues an UpdateClinicianSpecialCase job" do
        clinician_mart = create(:clinician_mart)
        UpdateClinicianSpecialCaseWorker.perform_async(clinician_mart.clinician_id, clinician_mart.license_key)

        expect(UpdateClinicianSpecialCaseWorker.jobs.size).to eq(1)
        expect(UpdateClinicianSpecialCaseWorker).to have_enqueued_sidekiq_job(clinician_mart.clinician_id,
                                                                              clinician_mart.license_key)
      end

      it "receive update_special_cases from the clinician_special_cases_sync" do
        clinician_mart = create(:clinician_mart)

        Sidekiq::Testing.inline! do
          expect(ClinicianSpecialCaseSync).to receive(:update_special_cases).with(clinician_mart.clinician_id,
                                                                                  clinician_mart.license_key)

          UpdateClinicianSpecialCaseWorker.perform_async(clinician_mart.clinician_id, clinician_mart.license_key)
          ClinicianUpdaterWorker.perform_async(clinician_mart.clinician_id, clinician_mart.license_key)
        end
      end

      it "creates clinician_special_cases from clinician_mart special_cases" do
        clinician_mart = create(:clinician_mart)
        create(:clinician)
        create(:special_case, name: "Recently discharged from a psychiatric hospital")
        Sidekiq::Testing.inline! do
          ClinicianUpdaterWorker.perform_async(clinician_mart.clinician_id, clinician_mart.license_key)
          special_case_count_before = Clinician.first.special_cases.count
          special_cases = ClinicianSpecialCaseSync.get_lfs_special_cases(clinician_mart)

          UpdateClinicianSpecialCaseWorker.perform_async(Clinician.first.id, special_cases)

          expect(Clinician.first.special_cases.count).to be > special_case_count_before
          expect(AuditJob.count).to eq(audit_job_count + 2)
          expect(AuditJob.last.job_name).to eq "UpdateClinicianSpecialCaseWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end
    end
    
    context 'Sad path' do
      before do
        allow(ClinicianSpecialCaseSync).to receive(:update_special_cases).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { UpdateClinicianSpecialCaseWorker.perform_async(1, {}) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "UpdateClinicianSpecialCaseWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
