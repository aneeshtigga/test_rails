require "rails_helper"
RSpec.describe ImportCarrierCategoriesWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ImportCarrierCategoriesWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ImportCarrierCategoriesWorker" do
    let!(:clinician1_carrier_insurance) { create(:carrier_insurance) }
    let!(:clinician2_carrier_insurance) { create(:carrier_insurance) }
    let!(:clinician3_carrier_insurance) { create(:carrier_insurance) }

    let!(:clinician) { create(:clinician, provider_id: clinician1_carrier_insurance.clinician_id) }
    let!(:clinician2) { create(:clinician, provider_id: clinician2_carrier_insurance.clinician_id) }
    let!(:clinician3) { create(:clinician, provider_id: clinician3_carrier_insurance.clinician_id) }

    let!(:address) do
      create(:clinician_address, clinician: clinician, facility_id: clinician1_carrier_insurance.facility_id,
                                 provider_id: clinician1_carrier_insurance.clinician_id)
    end
    let!(:clinician2_address) do
      create(:clinician_address, clinician: clinician2, facility_id: clinician2_carrier_insurance.facility_id,
                                 provider_id: clinician2_carrier_insurance.clinician_id)
    end
    let!(:clinician3_address) do
      create(:clinician_address, clinician: clinician3, facility_id: clinician3_carrier_insurance.facility_id,
                                 provider_id: clinician3_carrier_insurance.clinician_id)
    end

    it "enqueues an ImportCarrierCategoriesWorker job" do
      ImportCarrierCategoriesWorker.perform_async
      expect(ImportCarrierCategoriesWorker.jobs.size).to eq(1)
    end

    it "enqueues a AssociateFacilitiesToInsuranceWorker for each clinician" do 
      expect{ImportCarrierCategoriesWorker.new.perform}.to change(AssociateFacilitiesToInsuranceWorker.jobs, :size).by(3) 
    end

    it "imports insurances and facility accepted insurances from the carrier_insurances" do
      insurance_count = Insurance.count
      facility_accepted_count = FacilityAcceptedInsurance.count
      Sidekiq::Testing.inline! do
        ImportCarrierCategoriesWorker.perform_async
        expect(Insurance.count).to be > insurance_count
        expect(FacilityAcceptedInsurance.count).to be > facility_accepted_count
      end
    end

    it "imports insurances along with salesforce fields" do
      insurance_count = Insurance.count
      facility_accepted_count = FacilityAcceptedInsurance.count
      Sidekiq::Testing.inline! do
        ImportCarrierCategoriesWorker.perform_async
        expect(Insurance.count).to be > insurance_count
        expect(Insurance.first.obie_external_display).should_not be_nil
        expect(Insurance.first.abie_intake_internal_display).should_not be_nil
        expect(Insurance.first.website_display).should_not be_nil
        expect(Insurance.first.enrollment_effective_from).should_not be_nil
      end
    end

    it "doesn't create a duplicate record if already exists" do
      Sidekiq::Testing.inline! do
        ImportCarrierCategoriesWorker.perform_async
        insurance_count = Insurance.count
        accepted_insurance_count = FacilityAcceptedInsurance.count
        facility_accepted_count = FacilityAcceptedInsurance.count
        expect(Insurance.count).to eq insurance_count
        expect(FacilityAcceptedInsurance.count).to eq facility_accepted_count
      end
    end

    it "creates an audit_job record" do
      expect{ImportCarrierCategoriesWorker.new.perform}.to change(AuditJob, :count).by(1)
    end
  end
end
