require "rails_helper"
require "sidekiq/testing"

RSpec.describe ImportClinicianMartWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ImportClinicianMartWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ImportClinicianMartWorker" do
    it "enqueues an ImportClinicianMart job" do
      create(:clinician_mart)

      ImportClinicianMartWorker.perform_async

      expect(ImportClinicianMartWorker.jobs.size).to eq(1)
      expect(ImportClinicianMartWorker).to have_enqueued_sidekiq_job
    end

    it "imports data from the clinician mart" do
      Sidekiq::Testing.inline! do
        expect(ClinicianMartSync).to receive(:import_data).and_call_original

        ImportClinicianMartWorker.perform_async
      end
    end
  end
end
