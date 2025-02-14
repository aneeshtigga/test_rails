require "rails_helper"

describe AdvancedNoticeRule, type: :class do
  include ActiveSupport::Testing::TimeHelpers
  let!(:stub_time) { Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday

  before do
    travel_to stub_time
  end

  after do
    travel_back
  end

  let!(:clinician) { create(:clinician, telehealth_url: "https://telehealthurl.com") }

  describe "#passes_for?" do

    context "on Wednesday" do
      before { travel_to Time.new(2021, 12, 1, 9, 0, 0, "utc") } # Wednesday 9am
      after  { travel_back }

      context "when the appointment is in 12 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 12.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 24 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 24.hours) }

        it "returns true" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be true
        end
      end
    end

    context "on Friday" do
      before { travel_to Time.new(2021, 12, 3, 9, 0, 0, "utc") } # Friday 9am
      after  { travel_back }

      context "when the appointment is in 12 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 12.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 24 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 24.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 48 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 48.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 71 hours" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 71.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 72 hours" do # 3 days
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 72.hours) }

        it "returns true" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be true
        end
      end
    end

    context "on Sunday" do
      before { travel_to Time.new(2021, 12, 5, 9, 0, 0, "utc") } # Sunday 9am
      after  { travel_back }

      context "when the appointment is in 12 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 12.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 24 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 24.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 47 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 47.hours) }

        it "returns false" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be false
        end
      end

      context "when the appointment is in 48 hrs" do
        let!(:appointment) { create(:appointment, clinician: clinician, start_time: Time.now.utc + 48.hours) }

        it "returns true" do
          expect(AdvancedNoticeRule.passes_for?(appointment)).to be true
        end
      end
    end

  end
end
