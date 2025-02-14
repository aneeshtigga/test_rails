require "rails_helper"
RSpec.describe AssociateFacilitiesToInsuranceWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(AssociateFacilitiesToInsuranceWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a AssociateFacilitiesToInsuranceWorker" do
    let!(:insurance1) { create(:insurance) }
    let!(:insurance2) { create(:insurance, license_key: "77848") }
    let!(:insurance3) { create(:insurance, license_key: "78948") }

    let!(:clinician1) { create(:clinician) }
    let!(:clinician2) { create(:clinician) }
    let!(:clinician3) { create(:clinician) }

    let!(:address1) do
      create(:clinician_address, clinician: clinician1, provider_id: clinician1.provider_id,
                                 facility_id: 1, office_key: insurance1.license_key)
    end
    let!(:address2) do
      create(:clinician_address, clinician: clinician2, provider_id: clinician2.provider_id, 
                                 facility_id: 2, office_key: insurance2.license_key)
    end
    let!(:address3) do
      create(:clinician_address, clinician: clinician3, provider_id: clinician3.provider_id,
                                 facility_id: 3, office_key: insurance3.license_key)
    end
    let!(:params) do
      {
        facility_id:      address1.facility_id,
        amd_carrier_id:   insurance1.amd_carrier_id,
        mds_carrier_name: insurance1.mds_carrier_name,
        office_key:       address1.office_key,
        clinician_id:     clinician1.provider_id
      }
    end

    context 'Happy path' do
      it "enqueues an AssociateFacilitiesToInsuranceWorker job" do
        AssociateFacilitiesToInsuranceWorker.perform_async(params)
        expect(AssociateFacilitiesToInsuranceWorker.jobs.size).to eq(1)
      end

      it "associates an address, clinician and a carrier insurance" do
        facility_accepted_count = FacilityAcceptedInsurance.count
        Sidekiq::Testing.inline! do
          AssociateFacilitiesToInsuranceWorker.perform_async(params)
          expect(FacilityAcceptedInsurance.count).to be > facility_accepted_count
          
          expect(AuditJob.last.job_name).to eq "AssociateFacilitiesToInsuranceWorker"
        end
      end

      it "doesn't create a duplicate record if it already exists" do
        Sidekiq::Testing.inline! do
          AssociateFacilitiesToInsuranceWorker.perform_async(params)
          facility_accepted_count = FacilityAcceptedInsurance.count
          AssociateFacilitiesToInsuranceWorker.perform_async(params)
          expect(FacilityAcceptedInsurance.count).to eq facility_accepted_count

          expect(AuditJob.last.job_name).to eq "AssociateFacilitiesToInsuranceWorker"
          expect(AuditJob.last.status).to eq "completed"
        end
      end
    end

    context 'Sad path' do
      before do
        allow(FacilityAcceptedInsurance).to receive(:where).and_raise(StandardError)
      end

      let!(:audit_job_count) { AuditJob.count }

      it "ensures the proper AuditJob is created" do
        Sidekiq::Testing.inline! do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          expect { AssociateFacilitiesToInsuranceWorker.perform_async(params) }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "AssociateFacilitiesToInsuranceWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
