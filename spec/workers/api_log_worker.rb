require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe ApiLogWorker, type: :worker do
  describe "Sidekiq Worker" do
    it "should respond to #perform" do
      expect(ApiLogWorker.new).to respond_to(:perform)
    end

    describe "ApiLogWorker" do
      it "should create a ApiRequestResponse record" do
        ApiLogWorker.perform_async({payload: '{}', response: '{}', headers: '{}', url: "", time: Time.zone.now})
        ApiLogWorker.drain
        expect(ApiRequestResponse.count).to eq 1
        expect(ApiRequestResponse.last).to have_attributes(payload: '{}', response: '{}', headers: '{}', url: "")
      end
    end
  end
end
