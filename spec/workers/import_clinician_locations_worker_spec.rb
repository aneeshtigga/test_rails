require "rails_helper"
RSpec.describe ImportClinicianLocationsWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ImportClinicianLocationsWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ImportClinicianLocations" do
    it "enqueues an ImportClinicianLocations job for imports" do
      create(:clinician_location_mart)

      ImportClinicianLocationsWorker.perform_async
      expect(ImportClinicianLocationsWorker.jobs.size).to eq(1)
      expect(ImportClinicianLocationsWorker).to have_enqueued_sidekiq_job
    end

    it "imports data from the clinician location mart" do
      Sidekiq::Testing.inline! do
        expect_any_instance_of(described_class).to receive(:perform)

        ImportClinicianLocationsWorker.perform_async
      end
    end
  end
end
