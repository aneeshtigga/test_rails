require "rails_helper"
RSpec.describe MonitoringSidekiqWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable false }

    it "responds to #perform" do
      expect(MonitoringSidekiqWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a MonitoringSidekiqWorker" do

    it "enqueues an MonitoringSidekiqWorker job" do

      MonitoringSidekiqWorker.perform_async

      expect(MonitoringSidekiqWorker.jobs.size).to eq(1)
    end
  end
end
