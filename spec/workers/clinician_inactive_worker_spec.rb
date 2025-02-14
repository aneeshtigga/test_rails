require "rails_helper"
require "sidekiq/testing"

RSpec.describe ClinicianInactiveWorker, type: :worker do
  describe "Sidekiq Worker" do
    it { should be_retryable false }

    it "responds to #perform" do
      expect(ClinicianInactiveWorker.new).to respond_to(:perform)
    end
  end

  describe "Enqueuing a ClinicianInactiveWorker" do
    it "enqueues an ClinicianInactiveWorker job" do

      ClinicianInactiveWorker.perform_async

      expect(ClinicianInactiveWorker.jobs.size).to eq(1)
    end

  end
end
