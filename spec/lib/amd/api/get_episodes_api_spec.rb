require "rails_helper"

RSpec.describe Amd::Api::GetEpisodesApi, type: :class do
  describe "#episode_id" do
    let(:config) do
      Amd::AmdConfiguration.setup do |config|
        config.request_endpoint = "xmlrpc/processrequest.aspx"
      end
    end

    let(:base_url) { "https://provapi.advancedmd.com/processrequest/api-101/LIFESTANCE" }
    let(:token) { "9954565fVnC0PeO5O48YlXNEiKSuS3pnu+fAACpa01MNP26fKlHrr2uB0ZRqF1LHhO3H5rZL5QJi/Tbel+KoFKXFlQoTYDh+P5noR37phofNVoHnz1YOjxwpKo5KRbbBg7k4bg9EGRR1iOqWZUNitsivQsNJYxiEsgTRaUiIY//mdsVW+RX2xLZkLAnPVs02BgtzvV/w+JYIfexSBLZhw8QLCeBg==" }
    let(:episodes) { Amd::Api::GetEpisodesApi.new(config, base_url, token) }

    before do
      authenticate_amd_api
    end

    describe "id exists" do
      it "returns the found episode id" do
        VCR.use_cassette('amd/test_episode_id_method') do
          patient_id = 5982717

          expect(episodes.episode_id(patient_id)).to_not be_nil
          expect(episodes.episode_id(patient_id)).to eq(5948273)
        end
      end
    end
  end
end
