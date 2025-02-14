require "rails_helper"
require "sidekiq/testing"

RSpec.describe ClinicianUpdaterWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable false }

    it "responds to #perform" do
      expect(ClinicianUpdaterWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianUpdaterWorker" do
    it "enqueues an ClinicianUpdaterWorker job" do
      create(:clinician_mart)

      ClinicianUpdaterWorker.perform_async

      expect(ClinicianUpdaterWorker.jobs.size).to eq(1)
      expect(ClinicianUpdaterWorker).to have_enqueued_sidekiq_job
    end
  end
end
