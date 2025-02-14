require "rails_helper"
require "sidekiq/testing"

RSpec.describe ClinicianDataWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ClinicianDataWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianDataWorker" do
    it "enqueues an ClinicianDataWorker job" do

      ClinicianDataWorker.perform_async

      expect(ClinicianDataWorker.jobs.size).to eq(1)
    end

  end
end
