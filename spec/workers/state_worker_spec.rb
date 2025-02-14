require "rails_helper"

RSpec.describe StateWorker, type: :worker do
  include ActiveJob::TestHelper

  describe "Sidekiq Worker" do
    it "should respond to #perform" do
      expect(StateWorker.new).to respond_to(:perform)
    end

    describe "StateWorker" do
      context 'Happy path' do
        let!(:audit_job_count) { AuditJob.count }

        it "should enqueue a ZipCode job" do
          stub_request(:get, "https://www.zipcodeapi.com/rest/#{Rails.application.credentials.zipcodeApi_key}/state-zips.json/NC")
            .to_return(body: { zip_codes: ["27041"] }.to_json) # had to replace demo key with paid key
          StateWorker.perform_later("NC")
          perform_enqueued_jobs
          expect(ZipCodeWorker).to have_been_enqueued.exactly(:once).with("27041")

          expect(AuditJob.count).to eq(audit_job_count + 1)
          expect(AuditJob.last.job_name).to eq "StateWorker"
          expect(AuditJob.last.status).to eq "completed"
        end

        it "should enqueue a StateWorker job When ZipCodeApi exceeds the limit" do
          VCR.use_cassette "update_zip_codes_zipcodeapi_failure" do
            StateWorker.perform_later("TX")
          end
          expect(StateWorker).to have_been_enqueued.exactly(:once).with("TX")
          expect(ZipCodeWorker).to_not have_been_enqueued
        end

        it "should enqueue a StateWorker job When ZipCodeApi exceeds the limit" do
          stub_request(:get, "https://www.zipcodeapi.com/rest/#{Rails.application.credentials.zipcodeApi_key}/state-zips.json/TX")
            .to_return(status: 429, body: nil, headers: {})
          StateWorker.perform_later("TX")
          expect(StateWorker).to have_been_enqueued.exactly(:once).with("TX")
          expect(ZipCodeWorker).to_not have_been_enqueued
        end
      end

      context 'Sad path' do
        let!(:audit_job_count) { AuditJob.count }

        it "ensures the proper AuditJob is created" do
          # We are allowing ErrorLogger to actually be hit, as it triggers the Bugsnag.notify
          expect(Bugsnag).to receive(:notify).once

          StateWorker.perform_later("Invalid")
          
          expect { perform_enqueued_jobs }.to raise_error(StandardError)
          expect(AuditJob.last.job_name).to eq "StateWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
