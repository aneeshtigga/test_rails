require "rails_helper"

RSpec.describe StatePostalCodeWorker, type: :worker do
  include ActiveJob::TestHelper

  before do
    %w[AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT
       NE NV NH NJ NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VA WA WV WI WY]
      .each do |state|
        create(:state, name: state)
      end
  end

  describe "Sidekiq Worker" do
    it "responds to #perform" do
      expect(StatePostalCodeWorker.new).to respond_to(:perform)
    end

    describe "StatePostalCodeWorker" do
      it "enqueues a job for each state" do
        StatePostalCodeWorker.perform_later
        expect(StatePostalCodeWorker).to have_been_enqueued.exactly(:once)
        perform_enqueued_jobs
        expect(StateWorker).to have_been_enqueued.exactly(51).times
      end

      it "staggers the processing of each state by 2 hours" do
        StatePostalCodeWorker.perform_later
        perform_enqueued_jobs
        job1_wait_time = Time.at(enqueued_jobs[0][:at]) - Time.now
        expect(job1_wait_time).to be < 10 # first job executes within 10 seconds
        job2_wait_time = Time.at(enqueued_jobs[1][:at]) - Time.now
        expect(job2_wait_time).to be > 7_000 # second job executes after 2 hours
        job3_wait_time = Time.at(enqueued_jobs[2][:at]) - Time.now
        expect(job3_wait_time).to be > 14_000 # third job executes after 4 hours
      end
    end
  end
end