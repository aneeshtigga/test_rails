require "rails_helper"
RSpec.describe ImportSpecialCasesWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ImportSpecialCasesWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ImportSpecialCasesWorker" do
    it "enqueues an ImportSpecialCase job" do
      create(:clinician_mart)

      ImportSpecialCasesWorker.perform_async

      expect(ImportSpecialCasesWorker.jobs.size).to eq(1)
      expect(ImportSpecialCasesWorker).to have_enqueued_sidekiq_job
    end

    it "imports data from the clinician mart special cases" do
      Sidekiq::Testing.inline! do
        expect(ClinicianSpecialCaseSync).to receive(:import_data).and_call_original

        ImportSpecialCasesWorker.perform_async
      end
    end
  end
end
