require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe ClinicianAvailabilityStatusPruneWorker, type: :worker do
  describe "Sidekiq Worker" do
    it "should respond to #perform" do
      expect(ClinicianAvailabilityStatusPruneWorker.new).to respond_to(:perform)
    end
  
    describe "ClinicianAvailabilityStatusPruneWorker" do

      it "should enqueue a ClinicianAvailabilityStatusPruneWorker job" do
        create(:clinician_availability_status)
        ClinicianAvailabilityStatusPruneWorker.perform_async

        expect(ClinicianAvailabilityStatusPruneWorker.jobs.size).to eq(1)
        expect(ClinicianAvailabilityStatusPruneWorker).to have_enqueued_sidekiq_job
      end

      it "should delete all ClinicianAvailabilityStatus records" do
        5.times { create(:clinician_availability_status) }

        expect(ClinicianAvailabilityStatus.count).to eq(5)
        ClinicianAvailabilityStatusPruneWorker.new.perform
        expect(ClinicianAvailabilityStatus.count).to eq(0)
      end
    end
  end
end
