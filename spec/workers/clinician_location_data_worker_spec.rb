require "rails_helper"
require "sidekiq/testing"

RSpec.describe ClinicianLocationDataWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable 1 }

    it "responds to #perform" do
      expect(ClinicianLocationDataWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianLocationDataWorker" do
    it "enqueues an ClinicianLocationDataWorker job" do

      ClinicianLocationDataWorker.perform_async

      expect(ClinicianLocationDataWorker.jobs.size).to eq(1)
    end

  end
end
