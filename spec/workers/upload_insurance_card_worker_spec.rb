require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe UploadInsuranceCardWorker, type: :worker do
  before :all do 
    LicenseKey.find_or_create_by(
      key:    995456,
      cbo:    149330,
      active: true
    )
  end

  describe "UploadInsuranceCardWorker Worker" do
    it "should respond to #perform" do
      expect(UploadInsuranceCardWorker.new).to respond_to(:perform)
    end

    describe "perform" do
      context 'Happy path' do
        let!(:skip_patient_amd) { skip_patient_amd_creation }
        let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }
        let!(:patient) { create(:patient, amd_patient_id: 5_983_957, marketing_referral_id: 123) }
        let!(:insurance) { create(:insurance) }
        let!(:clinician) { create(:clinician) }
        let!(:address) { create(:clinician_address, clinician: clinician) }
        let!(:facility_accepted_insurance) do
          create(:facility_accepted_insurance, insurance: insurance, clinician_address: address, clinician: clinician)
        end
        let!(:responsible_party) { create(:responsible_party) }

        let!(:insurance_coverage) do
          create(:insurance_coverage, patient: patient, policy_holder: responsible_party,
                                      relation_to_policy_holder: "self")
        end
        let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }
        let(:image1) { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "test1.png")) }
        let(:insurance_card_service) { InsuranceCardUploadService.new(insurance_coverage, { front_card: image1 }) }
        let!(:skip_insurance_coverage_amd) { skip_insurance_coverage_amd_creation }
        let!(:audit_job_count) { AuditJob.count }

        it "enqueue a job to upload a front_card" do
          Sidekiq::Testing.inline! do
            VCR.use_cassette("amd/upload_insurance_card_file_to_amd_success") do
              insurance_card_service.save
              insurance_coverage.reload
              UploadInsuranceCardWorker.new.perform(insurance_coverage.id, "front_card")
            end
          end

          expect(insurance_coverage.front_card_url).to_not eq(nil)
          expect(AuditJob.count).to eq(audit_job_count + 2)
          expect(AuditJob.last.job_name).to eq "UploadInsuranceCardWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end

      context 'Sad path' do
        before do
          allow(InsuranceCoverage).to receive(:find_by).and_raise(StandardError)
        end
        let!(:audit_job_count) { AuditJob.count }

        it "ensures the proper AuditJob is created" do
          Sidekiq::Testing.inline! do
            # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
            expect(Bugsnag).to receive(:notify).once

            expect { UploadInsuranceCardWorker.perform_async(1, '2') }.to raise_error(StandardError)
            expect(AuditJob.last.job_name).to eq "UploadInsuranceCardWorker"
            expect(AuditJob.last.status).to eq "failed"
            
            expect(AuditJob.count).to eq(audit_job_count + 1)
          end
        end
      end
    end
  end
end
