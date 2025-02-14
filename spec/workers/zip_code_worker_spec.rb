require "rails_helper"

RSpec.describe ZipCodeWorker, type: :worker do
  include ActiveJob::TestHelper

  describe "Sidekiq Worker" do
    it "should respond to #perform" do
      expect(ZipCodeWorker.new).to respond_to(:perform)
    end

    it "should have retry enabled" do
      expect(ZipCodeWorker.retry_on(StandardError)).to_not be_nil
    end

    describe "ZipCodeWorker" do
      context 'Happy path' do
        let!(:audit_job_count) { AuditJob.count }

        it "should create a PostalCode record" do
          PostalCode.delete_all
                  
          VCR.use_cassette "get_zip_code_degrees_success" do
            VCR.use_cassette "zip_codes_within_radius_success" do
              ZipCodeWorker.perform_later("27041")
              perform_enqueued_jobs
            end
          end
          expect(PostalCode.count).to eq 1
        end

        it "should enqueue a ZipCodeWorker job When ZipCodeApi exceeds the limit" do
          VCR.use_cassette "create_zip_code_zipcodeapi_failure" do
            ZipCodeWorker.perform_later("77657")
          end
          expect(ZipCodeWorker).to have_been_enqueued.exactly(:once).with("77657")
        end

        # TODO: Implement happy path audit job
      end

      context 'Sad path' do
        let!(:audit_job_count) { AuditJob.count }
  
        it "ensures the proper AuditJob is created" do
          allow(PostalCode).to receive(:create_zip_code).and_raise(StandardError)

          expect { ZipCodeWorker.new.perform('cookies') }.to raise_error(StandardError)

          expect(AuditJob.last.job_name).to eq "ZipCodeWorker"
          expect(AuditJob.last.status).to eq "failed"
          
          expect(AuditJob.count).to eq(audit_job_count + 1)
        end
      end
    end
  end
end
